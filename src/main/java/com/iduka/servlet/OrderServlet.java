package com.iduka.servlet;

import com.iduka.dao.*;
import com.iduka.model.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/buyer/order")
public class OrderServlet extends HttpServlet {

    private final OrderDAO   orderDAO   = new OrderDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int buyerId = (int) req.getSession().getAttribute("userId");
        try {
            req.setAttribute("orders", orderDAO.getByBuyer(buyerId));
        } catch (Exception e) { throw new ServletException(e); }
        req.getRequestDispatcher("/jsp/buyer/orders.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int buyerId = (int) req.getSession().getAttribute("userId");
        try {
            int productId      = Integer.parseInt(req.getParameter("productId"));
            int qty            = Integer.parseInt(req.getParameter("quantity"));
            String payMethod   = req.getParameter("paymentMethod");
            String mtnNumber   = req.getParameter("mtnNumber");
            String airtelNumber= req.getParameter("airtelNumber");

            Product p = productDAO.findById(productId);
            if (p == null || p.getStock() < qty) {
                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "&error=Insufficient+stock");
                return;
            }

            User u = (User) req.getSession().getAttribute("user");
            String address = u.getVillage() + ", " + u.getCell() + ", " + u.getSector()
                           + ", " + u.getDistrict() + ", " + u.getProvince() + ", " + u.getCountry();

            // Determine phone number to use for payment
            String payPhone = u.getPhone(); // default to profile phone
            String payDisplay = payMethod != null ? payMethod : "Mobile Money";

            if ("MTN MoMo".equals(payMethod)) {
                if (mtnNumber != null && !mtnNumber.isBlank()) payPhone = mtnNumber;
                payDisplay = "MTN MoMo";
            } else if ("Airtel Money".equals(payMethod)) {
                if (airtelNumber != null && !airtelNumber.isBlank()) payPhone = airtelNumber;
                payDisplay = "Airtel Money";
            } else if ("Bank Transfer".equals(payMethod)) {
                payDisplay = "Bank Transfer";
            } else if ("Cash on Delivery".equals(payMethod)) {
                payDisplay = "Cash on Delivery";
            }

            Order o = new Order();
            o.setBuyerId(buyerId);
            o.setSellerId(p.getSellerId());
            o.setProductId(productId);
            o.setQuantity(qty);
            o.setUnitPrice(p.getPrice());
            o.setTotalPrice(p.getPrice().multiply(BigDecimal.valueOf(qty)));
            o.setDeliveryAddress(address);
            o.setPaymentMethod(payDisplay);
            o.setBuyerPhone(payPhone); // ← save the phone for MoMo payment request

            int orderId = orderDAO.placeOrder(o);
            if (orderId > 0) {
                res.sendRedirect(req.getContextPath() + "/buyer/order?success=Order+placed+successfully!+Order+%23" + orderId);
            } else {
                res.sendRedirect(req.getContextPath() + "/product?id=" + productId + "&error=Order+failed");
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}
