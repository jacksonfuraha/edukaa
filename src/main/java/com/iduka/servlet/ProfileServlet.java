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

@WebServlet("/profile")
@MultipartConfig(maxFileSize = 5242880) // 5MB avatar
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int userId = (int) req.getSession().getAttribute("userId");
        try {
            User user = userDAO.findById(userId);
            req.setAttribute("profileUser", user);
            req.getRequestDispatcher("/jsp/common/profile.jsp").forward(req, res);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int userId = (int) req.getSession().getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                User u = userDAO.findById(userId);
                u.setFullName(req.getParameter("fullName"));
                u.setPhone(req.getParameter("phone"));
                u.setCountry(req.getParameter("country"));
                u.setProvince(req.getParameter("province"));
                u.setDistrict(req.getParameter("district"));
                u.setSector(req.getParameter("sector"));
                u.setCell(req.getParameter("cell"));
                u.setVillage(req.getParameter("village"));
                userDAO.updateProfile(u);
                // Update session name
                req.getSession().setAttribute("userName", u.getFullName());
                res.sendRedirect(req.getContextPath() + "/profile?success=Profile+updated+successfully");

            } else if ("changePassword".equals(action)) {
                String oldPw  = req.getParameter("oldPassword");
                String newPw  = req.getParameter("newPassword");
                String confPw = req.getParameter("confirmPassword");
                if (!newPw.equals(confPw)) {
                    req.setAttribute("pwError", "New passwords do not match.");
                } else if (newPw.length() < 6) {
                    req.setAttribute("pwError", "Password must be at least 6 characters.");
                } else if (!userDAO.changePassword(userId, oldPw, newPw)) {
                    req.setAttribute("pwError", "Current password is incorrect.");
                } else {
                    res.sendRedirect(req.getContextPath() + "/profile?success=Password+changed+successfully");
                    return;
                }
                User u = userDAO.findById(userId);
                req.setAttribute("profileUser", u);
                req.setAttribute("activeTab", "password");
                req.getRequestDispatcher("/jsp/common/profile.jsp").forward(req, res);

            } else if ("uploadAvatar".equals(action)) {
                Part avatarPart = req.getPart("avatar");
                if (avatarPart != null && avatarPart.getSize() > 0) {
                    String origName = avatarPart.getSubmittedFileName();
                    String ext = origName.contains(".")
                        ? origName.substring(origName.lastIndexOf('.')).toLowerCase() : ".jpg";
                    String fileName = "avatar_" + userId + ext;
                    Path dest = Paths.get(com.iduka.util.UploadConfig.getUploadBase(), "avatars", fileName);
                    Files.createDirectories(dest.getParent());
                    try (InputStream in = avatarPart.getInputStream()) {
                        Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
                    }
                    String avatarPath = "avatars/" + fileName;
                    userDAO.updateAvatar(userId, avatarPath);

                    // ✅ Refresh session immediately — no re-login needed
                    User freshUser = userDAO.findById(userId);
                    HttpSession sess = req.getSession();
                    sess.setAttribute("user",     freshUser);
                    sess.setAttribute("userName", freshUser.getFullName());
                }
                res.sendRedirect(req.getContextPath() + "/profile?success=Photo+updated");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}
