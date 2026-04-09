package com.iduka.servlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        HttpSession session=req.getSession(false);
        if(session!=null) session.invalidate();
        res.sendRedirect(req.getContextPath()+"/");
    }
}
