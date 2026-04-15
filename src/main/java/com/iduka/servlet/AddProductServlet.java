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
import java.util.UUID;

@WebServlet("/seller/addProduct")
@MultipartConfig(maxFileSize = 10485760, maxRequestSize = 20971520)
public class AddProductServlet extends HttpServlet {

    private final ProductDAO  productDAO  = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    private static final String UPLOAD_BASE =
        com.iduka.util.UploadConfig.getUploadBase();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try { req.setAttribute("categories", categoryDAO.getAll()); }
        catch (Exception e) { throw new ServletException(e); }
        req.getRequestDispatcher("/jsp/seller/add_product.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int sellerId = (int) req.getSession().getAttribute("userId");
        try {
            String imageUrl = ""; // empty = no image uploaded

            Part imagePart = req.getPart("image");
            if (imagePart != null && imagePart.getSize() > 0) {
                String origName = imagePart.getSubmittedFileName();
                if (origName != null && !origName.isBlank()) {
                    String ext = origName.contains(".")
                        ? origName.substring(origName.lastIndexOf('.')).toLowerCase() : ".jpg";
                    if (!ext.matches("\\.(jpg|jpeg|png|gif|webp)")) ext = ".jpg";

                    String fileName = UUID.randomUUID() + ext;
                    Path dir  = Paths.get(UPLOAD_BASE, "products");
                    Path dest = dir.resolve(fileName);
                    Files.createDirectories(dir);

                    try (InputStream in = imagePart.getInputStream()) {
                        Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
                    }
                    // Store as "products/uuid.jpg" — served at /uploads/products/uuid.jpg
                    imageUrl = "products/" + fileName;
                }
            }

            Product p = new Product();
            p.setSellerId(sellerId);
            p.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
            p.setName(req.getParameter("name"));
            p.setDescription(req.getParameter("description"));
            p.setPrice(new BigDecimal(req.getParameter("price")));
            p.setStock(Integer.parseInt(req.getParameter("stock")));
            p.setImageUrl(imageUrl);
            productDAO.addProduct(p);
            res.sendRedirect(req.getContextPath() + "/seller/dashboard?success=Product+added!");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
