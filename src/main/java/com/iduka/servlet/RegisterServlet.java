package com.iduka.servlet;

import com.iduka.dao.NotificationDAO;
import com.iduka.dao.UserDAO;
import com.iduka.model.User;
import com.iduka.util.RwandaValidator;
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

    private final UserDAO         userDAO  = new UserDAO();
    private final NotificationDAO notifDAO = new NotificationDAO();

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

        String fullName = clean(req.getParameter("fullName"));
        String email    = clean(req.getParameter("email"));
        String phone    = clean(req.getParameter("phone"));
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirmPassword");
        String role     = clean(req.getParameter("role"));

        // ── Basic field validation ────────────────────────────────────────
        if (fullName.isEmpty() || email.isEmpty() || password == null || role.isEmpty()) {
            error(req, res, "Please fill in all required fields."); return;
        }
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            error(req, res, "Please enter a valid email address."); return;
        }
        if (password.length() < 6) {
            error(req, res, "Password must be at least 6 characters."); return;
        }
        if (!password.equals(confirm)) {
            error(req, res, "Passwords do not match."); return;
        }
        if (phone != null && !phone.isEmpty() &&
            !phone.replaceAll("[\\s\\-]","").matches("(07[2-9]\\d{7}|250\\d{9})")) {
            error(req, res, "Please enter a valid Rwanda phone number (e.g. 0781234567)."); return;
        }

        try {
            // ── Check email duplicate ─────────────────────────────────────
            if (userDAO.emailExists(email)) {
                error(req, res, "This email address is already registered. Please login instead."); return;
            }

            // ── Seller-specific validation ────────────────────────────────
            String idNumber = null;
            String tinNumber = null;

            if ("SELLER".equals(role)) {
                idNumber  = clean(req.getParameter("idNumber")).replaceAll("\\s+", "");
                tinNumber = clean(req.getParameter("tinNumber")).replaceAll("\\s+", "");

                // Validate full name for sellers
                String nameErr = RwandaValidator.validateSellerName(fullName);
                if (nameErr != null) { error(req, res, nameErr); return; }

                // Validate National ID format
                String idErr = RwandaValidator.validateNationalId(idNumber);
                if (idErr != null) { error(req, res, idErr); return; }

                // Validate TIN format
                String tinErr = RwandaValidator.validateTIN(tinNumber);
                if (tinErr != null) { error(req, res, tinErr); return; }

                // Check if National ID already used by another account
                if (userDAO.idNumberExists(idNumber)) {
                    error(req, res,
                        "This National ID (" + idNumber + ") is already registered to another account. " +
                        "If this is your ID, please contact support."); return;
                }

                // Check if TIN already used by another account
                if (userDAO.tinExists(tinNumber)) {
                    error(req, res,
                        "This TIN number (" + tinNumber + ") is already registered to another business. " +
                        "Each TIN can only be used once."); return;
                }

                // ID card photo is MANDATORY for sellers
                Part idCardPart = req.getPart("idCard");
                if (idCardPart == null || idCardPart.getSize() == 0) {
                    error(req, res,
                        "You must upload a photo of your National ID card. " +
                        "This is required to verify your identity before you can sell."); return;
                }

                // Validate file type
                String origName = idCardPart.getSubmittedFileName();
                if (origName == null || !origName.toLowerCase().matches(".*\\.(jpg|jpeg|png|webp)$")) {
                    error(req, res, "ID card photo must be a JPG or PNG image file."); return;
                }

                // File size check (max 5MB)
                if (idCardPart.getSize() > 5 * 1024 * 1024) {
                    error(req, res, "ID card photo is too large. Maximum size is 5MB."); return;
                }
            }

            // ── Create user account ───────────────────────────────────────
            User u = new User();
            u.setFullName(fullName); u.setEmail(email); u.setPhone(phone);
            u.setPassword(password); u.setRole(role);
            u.setCountry(clean(req.getParameter("country")));
            u.setProvince(clean(req.getParameter("province")));
            u.setDistrict(clean(req.getParameter("district")));
            u.setSector(clean(req.getParameter("sector")));
            u.setCell(clean(req.getParameter("cell")));
            u.setVillage(clean(req.getParameter("village")));

            if ("SELLER".equals(role)) {
                u.setIdNumber(idNumber);
                u.setTinNumber(tinNumber);
                u.setVerified(false); // Requires admin approval
            }

            boolean ok = userDAO.register(u);
            if (!ok) {
                error(req, res, "Registration failed. Please try again."); return;
            }

            // ── Upload ID card photo ──────────────────────────────────────
            if ("SELLER".equals(role)) {
                try {
                    Part idCardPart = req.getPart("idCard");
                    if (idCardPart != null && idCardPart.getSize() > 0) {
                        String orig = idCardPart.getSubmittedFileName();
                        String ext  = orig.substring(orig.lastIndexOf('.')).toLowerCase();
                        String fileName = "idcard_" + UUID.randomUUID() + ext;

                        // Try Cloudinary first for permanent storage
                        String idCardUrl;
                        if (com.iduka.util.CloudinaryConfig.isEnabled()) {
                            try (InputStream in = idCardPart.getInputStream()) {
                                idCardUrl = com.iduka.util.CloudinaryConfig.uploadImage(in, fileName);
                            } catch (Exception e) {
                                // Fallback to local
                                Path dir = Paths.get(UPLOAD_BASE, "avatars");
                                Files.createDirectories(dir);
                                try (InputStream in = idCardPart.getInputStream()) {
                                    Files.copy(in, dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
                                }
                                idCardUrl = "avatars/" + fileName;
                            }
                        } else {
                            Path dir = Paths.get(UPLOAD_BASE, "avatars");
                            Files.createDirectories(dir);
                            try (InputStream in = idCardPart.getInputStream()) {
                                Files.copy(in, dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
                            }
                            idCardUrl = "avatars/" + fileName;
                        }

                        User registered = userDAO.login(email, password);
                        if (registered != null) {
                            userDAO.updateIdCard(registered.getId(), idCardUrl);
                        }
                    }
                } catch (Exception e) {
                    System.err.println("ID card upload failed: " + e.getMessage());
                }

                // Notify admin about new seller pending review
                try {
                    // Find admin accounts and notify them
                    notifDAO.create(1, "ORDER",
                        "🆕 New seller registration pending review: " + fullName +
                        " (ID: " + idNumber + ", TIN: " + tinNumber + ")",
                        "/admin/sellers");
                } catch (Exception ignored) {}

                res.sendRedirect(req.getContextPath() +
                    "/login?success=Account+created!+" +
                    "Your+seller+account+is+pending+verification.+" +
                    "You+will+be+notified+once+approved+by+our+team.");
            } else {
                res.sendRedirect(req.getContextPath() +
                    "/login?success=Account+created!+Please+login.");
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private void error(HttpServletRequest req, HttpServletResponse res, String msg)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req, res);
    }

    private String clean(String s) {
        return s != null ? s.trim() : "";
    }
}
