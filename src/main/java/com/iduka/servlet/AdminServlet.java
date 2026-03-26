package com.iduka.servlet;

import com.iduka.dao.NotificationDAO;
import com.iduka.dao.UserDAO;
import com.iduka.model.User;
import com.iduka.util.EmailService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/admin/sellers", "/admin/verify"})
public class AdminServlet extends HttpServlet {

    private final UserDAO         userDAO  = new UserDAO();
    private final NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/home"); return;
        }
        try {
            req.setAttribute("pendingSellers", userDAO.getPendingSellers());
            req.getRequestDispatcher("/jsp/admin/sellers.jsp").forward(req, res);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        if (!isAdmin(req.getSession(false))) {
            res.sendRedirect(req.getContextPath() + "/home"); return;
        }
        try {
            int     userId   = Integer.parseInt(req.getParameter("userId"));
            boolean approved = "approve".equals(req.getParameter("action"));

            // Get seller details before updating
            User seller = userDAO.findById(userId);

            // Update verification status
            userDAO.updateSellerVerification(userId, approved);

            if (seller != null) {
                if (approved) {
                    // Notify seller via IDUKA notification
                    notifDAO.create(userId, "ORDER_STATUS",
                        "🎉 Congratulations! Your seller account has been verified and approved. You can now add products and start selling!",
                        "/seller/dashboard");

                    // Send approval email
                    if (seller.getEmail() != null) {
                        EmailService.sendSellerApproved(seller.getEmail(), seller.getFullName());
                    }
                } else {
                    // Notify seller of rejection
                    notifDAO.create(userId, "ORDER_STATUS",
                        "❌ Your seller account application was not approved. Please contact support for more information.",
                        "/login");

                    // Send rejection email
                    if (seller.getEmail() != null) {
                        EmailService.sendSellerRejected(seller.getEmail(), seller.getFullName(),
                            "Your identity documents could not be verified. Please ensure your National ID photo is clear and all details match your official ID.");
                    }
                }
            }

            String msg = approved
                ? "Seller+" + (seller != null ? seller.getFullName().replace(" ","+") : "") + "+approved+and+notified!"
                : "Seller+application+rejected.+They+have+been+notified.";
            res.sendRedirect(req.getContextPath() + "/admin/sellers?success=" + msg);

        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        User user = (User) session.getAttribute("user");
        return user != null && (user.getId() == 1 || "ADMIN".equals(session.getAttribute("userRole")));
    }
}
