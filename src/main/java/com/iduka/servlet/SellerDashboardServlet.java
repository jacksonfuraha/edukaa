package com.iduka.servlet;
import com.iduka.dao.*;
import com.iduka.model.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.math.BigDecimal;
import java.nio.file.*;
import java.util.*;

@WebServlet("/seller/dashboard")
@MultipartConfig(maxFileSize = 10485760)
public class SellerDashboardServlet extends HttpServlet {
    private final ProductDAO  productDAO  = new ProductDAO();
    private final OrderDAO    orderDAO    = new OrderDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final VideoDAO    videoDAO    = new VideoDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int sellerId = (int) req.getSession().getAttribute("userId");
        try {
            req.setAttribute("products",   productDAO.getBySeller(sellerId));
            req.setAttribute("orders",     orderDAO.getBySeller(sellerId));
            req.setAttribute("categories", categoryDAO.getAll());
            req.setAttribute("myVideos",   videoDAO.getBySeller(sellerId));

            // Summary stats
            List<Order> orders = orderDAO.getBySeller(sellerId);
            int pending = 0; double revenue = 0;
            for (Order o : orders) {
                if ("PENDING".equals(o.getStatus())) pending++;
                if ("DELIVERED".equals(o.getStatus()) || "CONFIRMED".equals(o.getStatus()))
                    if (o.getTotalPrice() != null) revenue += o.getTotalPrice().doubleValue();
            }
            req.setAttribute("pendingCount", pending);
            req.setAttribute("totalRevenue", String.format("%.0f", revenue));
        } catch (Exception e) { throw new ServletException(e); }
        req.getRequestDispatcher("/jsp/seller/dashboard.jsp").forward(req, res);
    }
}
