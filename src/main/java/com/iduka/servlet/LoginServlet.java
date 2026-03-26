package com.iduka.servlet;
import com.iduka.dao.UserDAO;
import com.iduka.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO=new UserDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, res);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String email=req.getParameter("email");
        String password=req.getParameter("password");
        try {
            // Server-side validation
            if (email == null || email.trim().isEmpty()) {
                req.setAttribute("error", "Email address is required.");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, res); return;
            }
            if (!email.trim().matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                req.setAttribute("error", "Please enter a valid email address.");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, res); return;
            }
            if (password == null || password.isEmpty()) {
                req.setAttribute("error", "Password is required.");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, res); return;
            }
            User u=userDAO.login(email, password);
            if(u!=null){
                HttpSession session=req.getSession(true);
                session.setAttribute("user",u);
                session.setAttribute("userId",u.getId());
                session.setAttribute("userRole",u.getRole());
                session.setAttribute("userName",u.getFullName());
                if("SELLER".equals(u.getRole())) res.sendRedirect(req.getContextPath()+"/seller/dashboard");
                else res.sendRedirect(req.getContextPath()+"/buyer/home");
            } else {
                req.setAttribute("error","Invalid email or password.");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, res);
            }
        } catch(Exception e){ throw new ServletException(e); }
    }
}
