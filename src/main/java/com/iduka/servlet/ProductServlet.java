package com.iduka.servlet;
import com.iduka.dao.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet("/product")
public class ProductServlet extends HttpServlet {
    private final ProductDAO productDAO=new ProductDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String idStr=req.getParameter("id");
        if(idStr==null){ res.sendRedirect(req.getContextPath()+"/home"); return; }
        try {
            req.setAttribute("product", productDAO.findById(Integer.parseInt(idStr)));
        } catch(Exception e){ throw new ServletException(e); }
        req.getRequestDispatcher("/jsp/common/product_detail.jsp").forward(req, res);
    }
}
