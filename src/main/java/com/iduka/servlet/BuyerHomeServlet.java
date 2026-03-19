package com.iduka.servlet;
import com.iduka.dao.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet("/buyer/home")
public class BuyerHomeServlet extends HttpServlet {
    private final ProductDAO productDAO=new ProductDAO();
    private final CategoryDAO categoryDAO=new CategoryDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            req.setAttribute("products", productDAO.getAllActive());
            req.setAttribute("categories", categoryDAO.getAll());
        } catch(Exception e){ throw new ServletException(e); }
        req.getRequestDispatcher("/jsp/buyer/home.jsp").forward(req, res);
    }
}
