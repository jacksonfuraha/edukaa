package com.iduka.servlet;
import com.iduka.dao.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/", "/home"})
public class HomeServlet extends HttpServlet {
    private final ProductDAO productDAO=new ProductDAO();
    private final CategoryDAO categoryDAO=new CategoryDAO();
    private final VideoDAO videoDAO=new VideoDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            req.setAttribute("products", productDAO.getAllActive());
            req.setAttribute("categories", categoryDAO.getAll());
            req.setAttribute("videos", videoDAO.getAll());
            String search=req.getParameter("search");
            if(search!=null && !search.trim().isEmpty()){
                req.setAttribute("products", productDAO.search(search.trim()));
                req.setAttribute("search", search);
            }
            String catId=req.getParameter("catId");
            if(catId!=null && !catId.isEmpty()){
                req.setAttribute("products", productDAO.getByCategory(Integer.parseInt(catId)));
            }
        } catch(Exception e){ throw new ServletException(e); }
        req.getRequestDispatcher("/jsp/common/home.jsp").forward(req, res);
    }
}
