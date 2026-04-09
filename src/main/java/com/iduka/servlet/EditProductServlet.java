package com.iduka.servlet;

import com.iduka.dao.*;
import com.iduka.model.Product;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.math.BigDecimal;
import java.nio.file.*;
import java.util.UUID;

@WebServlet(urlPatterns = {"/seller/editProduct", "/seller/deleteProduct"})
@MultipartConfig(maxFileSize = 10485760)
public class EditProductServlet extends HttpServlet {

    private final ProductDAO  productDAO  = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private static final String UPLOAD_BASE =
        com.iduka.util.UploadConfig.getUploadBase();

    // GET /seller/editProduct?id=X  → show edit form
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int sellerId = (int) req.getSession().getAttribute("userId");

        // DELETE via GET ?action=delete&id=X
        if ("delete".equals(req.getParameter("action"))) {
            try {
                int pid = Integer.parseInt(req.getParameter("id"));
                productDAO.deleteProduct(pid, sellerId);
            } catch (Exception e) { /* ignore */ }
            res.sendRedirect(req.getContextPath() + "/seller/dashboard?tab=products&msg=deleted");
            return;
        }

        try {
            int pid = Integer.parseInt(req.getParameter("id"));
            Product p = productDAO.findById(pid);
            if (p == null || p.getSellerId() != sellerId) {
                res.sendRedirect(req.getContextPath() + "/seller/dashboard");
                return;
            }
            req.setAttribute("product",    p);
            req.setAttribute("categories", categoryDAO.getAll());
            req.getRequestDispatcher("/jsp/seller/edit_product.jsp").forward(req, res);
        } catch (Exception e) { throw new ServletException(e); }
    }

    // POST /seller/editProduct  → save changes
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int sellerId = (int) req.getSession().getAttribute("userId");
        try {
            int pid = Integer.parseInt(req.getParameter("id"));
            Product p = productDAO.findById(pid);
            if (p == null || p.getSellerId() != sellerId) {
                res.sendRedirect(req.getContextPath() + "/seller/dashboard"); return;
            }

            p.setName(req.getParameter("name"));
            p.setDescription(req.getParameter("description"));
            p.setPrice(new BigDecimal(req.getParameter("price")));
            p.setStock(Integer.parseInt(req.getParameter("stock")));
            p.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
            p.setActive("on".equals(req.getParameter("active")) || "true".equals(req.getParameter("active")));

            // Handle new image upload
            try {
                Part imgPart = req.getPart("image");
                if (imgPart != null && imgPart.getSize() > 0) {
                    String orig = imgPart.getSubmittedFileName();
                    String ext  = (orig != null && orig.contains("."))
                        ? orig.substring(orig.lastIndexOf('.')).toLowerCase() : ".jpg";
                    if (!ext.matches("\\.(jpg|jpeg|png|webp|gif)")) ext = ".jpg";
                    String fileName = UUID.randomUUID() + ext;
                    Path dir = Paths.get(UPLOAD_BASE, "products");
                    Files.createDirectories(dir);
                    try (InputStream in = imgPart.getInputStream()) {
                        Files.copy(in, dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
                    }
                    p.setImageUrl("products/" + fileName);
                }
            } catch (Exception ignored) {}

            productDAO.updateProduct(p);
            res.sendRedirect(req.getContextPath() + "/seller/dashboard?tab=products&msg=updated");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
