package com.iduka.servlet;

import com.iduka.dao.UserDAO;
import com.iduka.model.User;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;

@WebServlet("/register")
@MultipartConfig(maxFileSize = 5242880)
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final String UPLOAD_BASE =
        com.iduka.util.UploadConfig.getUploadBase();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email    = req.getParameter("email");
        String phone    = req.getParameter("phone");
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirmPassword");
        String role     = req.getParameter("role");

        if (fullName==null||email==null||password==null||role==null
                ||fullName.isBlank()||email.isBlank()||password.isBlank()) {
            req.setAttribute("error","Please fill all required fields.");
            req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req,res); return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error","Passwords do not match.");
            req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req,res); return;
        }
        if (password.length() < 6) {
            req.setAttribute("error","Password must be at least 6 characters.");
            req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req,res); return;
        }
        // Seller-specific validation
        if ("SELLER".equals(role)) {
            String idNum = req.getParameter("idNumber");
            String tin   = req.getParameter("tinNumber");
            if (idNum==null||idNum.isBlank()||tin==null||tin.isBlank()) {
                req.setAttribute("error","Sellers must provide their National ID number and TIN number.");
                req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req,res); return;
            }
        }

        try {
            if (userDAO.emailExists(email)) {
                req.setAttribute("error","This email is already registered.");
                req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req,res); return;
            }
            User u = new User();
            u.setFullName(fullName); u.setEmail(email); u.setPhone(phone);
            u.setPassword(password); u.setRole(role);
            u.setCountry(req.getParameter("country"));
            u.setProvince(req.getParameter("province"));
            u.setDistrict(req.getParameter("district"));
            u.setSector(req.getParameter("sector"));
            u.setCell(req.getParameter("cell"));
            u.setVillage(req.getParameter("village"));
            if ("SELLER".equals(role)) {
                u.setIdNumber(req.getParameter("idNumber"));
                u.setTinNumber(req.getParameter("tinNumber"));
            }
            boolean ok = userDAO.register(u);
            if (!ok) {
                req.setAttribute("error","Registration failed. Please try again.");
                req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req,res); return;
            }

            // Upload ID card photo for sellers
            if ("SELLER".equals(role)) {
                try {
                    Part idCardPart = req.getPart("idCard");
                    if (idCardPart != null && idCardPart.getSize() > 0) {
                        String ext = ".jpg";
                        String orig = idCardPart.getSubmittedFileName();
                        if (orig != null && orig.contains("."))
                            ext = orig.substring(orig.lastIndexOf('.')).toLowerCase();
                        String fileName = "idcard_" + UUID.randomUUID() + ext;
                        Path dir = Paths.get(UPLOAD_BASE, "avatars");
                        Files.createDirectories(dir);
                        try (InputStream in = idCardPart.getInputStream()) {
                            Files.copy(in, dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
                        }
                        // Get the newly registered user's ID and save card
                        User registered = userDAO.login(email, password);
                        if (registered != null) {
                            userDAO.updateIdCard(registered.getId(), "avatars/" + fileName);
                        }
                    }
                } catch (Exception ignored) {}
            }

            res.sendRedirect(req.getContextPath()+"/login?success=Account+created!+Please+login.");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
