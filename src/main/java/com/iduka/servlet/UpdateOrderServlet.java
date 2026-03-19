package com.iduka.servlet;

import com.iduka.dao.OrderDAO;
import com.iduka.dao.NotificationDAO;
import com.iduka.model.Order;
import com.iduka.util.MoMoPaymentService;
import com.iduka.util.MoMoPaymentService.PaymentResult;
import com.iduka.util.EmailService;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet("/seller/updateOrder")
public class UpdateOrderServlet extends HttpServlet {
    private final OrderDAO        orderDAO = new OrderDAO();
    private final NotificationDAO notifDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        try {
            int    orderId   = Integer.parseInt(req.getParameter("orderId"));
            String newStatus = req.getParameter("status");

            if ("CONFIRMED".equals(newStatus)) {

                // 1. Load full order details
                Order order = orderDAO.getById(orderId);
                if (order == null) {
                    res.sendRedirect(req.getContextPath() + "/seller/dashboard?error=Order+not+found");
                    return;
                }

                // 2. Confirm the order in DB
                orderDAO.updateStatus(orderId, "CONFIRMED");

                String buyerPhone   = order.getBuyerPhone();
                double amount       = order.getTotalPrice()  != null ? order.getTotalPrice().doubleValue()  : 0;
                double unitPrice    = order.getUnitPrice()   != null ? order.getUnitPrice().doubleValue()   : amount;
                String product      = order.getProductName() != null ? order.getProductName() : "Product";
                String payMethod    = order.getPaymentMethod() != null ? order.getPaymentMethod() : "Mobile Money";
                String buyerEmail   = order.getBuyerEmail();
                String buyerName    = order.getBuyerName()   != null ? order.getBuyerName()   : "Customer";
                String sellerName   = order.getSellerName()  != null ? order.getSellerName()  : "Seller";
                String address      = order.getDeliveryAddress() != null ? order.getDeliveryAddress() : "";

                String redirectMsg;

                // 3. Handle Cash on Delivery — no MoMo, just send invoice
                if ("Cash on Delivery".equals(payMethod)) {
                    String ref = "IDK-COD-" + orderId;
                    orderDAO.updatePaymentRef(orderId, ref, "CASH", "PAYMENT_SENT");

                    // Notify buyer
                    notifDAO.create(order.getBuyerId(), "ORDER_STATUS",
                        "✅ Order #" + orderId + " (" + product + ") confirmed! " +
                        "Pay RWF " + (int)amount + " cash on delivery.", "/buyer/order");

                    // Send invoice email immediately
                    sendInvoiceAsync(buyerEmail, buyerName, orderId, product,
                        order.getQuantity(), unitPrice, amount, ref,
                        payMethod, buyerPhone, address, sellerName);

                    redirectMsg = "Order+confirmed!+Invoice+sent+to+buyer's+email.";

                // 4. Handle Bank Transfer
                } else if ("Bank Transfer".equals(payMethod)) {
                    String ref = "IDK-BANK-" + orderId + "-" + System.currentTimeMillis() % 10000;
                    orderDAO.updatePaymentRef(orderId, ref, "BANK", "PAYMENT_SENT");

                    notifDAO.create(order.getBuyerId(), "ORDER_STATUS",
                        "🏦 Order #" + orderId + " confirmed! Please transfer RWF " + (int)amount +
                        " to Bank of Kigali. Reference: ORDER-" + orderId, "/buyer/order");

                    // Send invoice with bank details
                    sendInvoiceAsync(buyerEmail, buyerName, orderId, product,
                        order.getQuantity(), unitPrice, amount, ref,
                        payMethod, buyerPhone, address, sellerName);

                    redirectMsg = "Order+confirmed!+Bank+transfer+invoice+sent+to+buyer's+email.";

                // 5. Handle MTN / Airtel MoMo
                } else {
                    if (buyerPhone != null && !buyerPhone.trim().isEmpty() && amount > 0) {

                        // Call MTN or Airtel API
                        PaymentResult payment = MoMoPaymentService.requestPayment(
                            buyerPhone, amount, orderId, product);

                        if (payment.success) {
                            // Save payment ref
                            orderDAO.updatePaymentRef(orderId, payment.reference, payment.method, "PAYMENT_SENT");

                            // Notify buyer on IDUKA
                            notifDAO.create(order.getBuyerId(), "ORDER_STATUS",
                                "💳 Payment request of RWF " + (int)amount + " sent to your " +
                                payment.method + " (" + buyerPhone + "). Please enter your PIN to complete.",
                                "/buyer/order");

                            // ✅ Send invoice email immediately after payment request
                            sendInvoiceAsync(buyerEmail, buyerName, orderId, product,
                                order.getQuantity(), unitPrice, amount, payment.reference,
                                payment.method + " MoMo", buyerPhone, address, sellerName);

                            // Notify seller
                            notifDAO.create(order.getSellerId(), "ORDER_STATUS",
                                "✅ Order #" + orderId + " confirmed. Payment request sent to " +
                                buyerPhone + " via " + payment.method + ".", "/seller/dashboard");

                            redirectMsg = "Order+confirmed!+Payment+request+%26+invoice+sent+to+" +
                                          buyerName.replace(" ", "+") + "+via+" + payment.method + ".";
                        } else {
                            // Payment request failed — still send invoice
                            String ref = "IDK-" + orderId + "-" + System.currentTimeMillis() % 10000;
                            orderDAO.updatePaymentRef(orderId, ref, payMethod, "PAYMENT_SENT");

                            notifDAO.create(order.getBuyerId(), "ORDER_STATUS",
                                "✅ Order #" + orderId + " (" + product + ") confirmed! " +
                                "Pay RWF " + (int)amount + " via " + payMethod + ". " +
                                "Invoice sent to your email.", "/buyer/order");

                            sendInvoiceAsync(buyerEmail, buyerName, orderId, product,
                                order.getQuantity(), unitPrice, amount, ref,
                                payMethod, buyerPhone, address, sellerName);

                            redirectMsg = "Order+confirmed!+Invoice+sent+to+buyer's+email.+" +
                                          "Payment+request+failed+(buyer+must+pay+manually).";
                        }
                    } else {
                        // No phone — just confirm and send invoice
                        String ref = "IDK-" + orderId;
                        orderDAO.updatePaymentRef(orderId, ref, payMethod, "PAYMENT_SENT");

                        notifDAO.create(order.getBuyerId(), "ORDER_STATUS",
                            "✅ Order #" + orderId + " confirmed! Invoice sent to your email.", "/buyer/order");

                        sendInvoiceAsync(buyerEmail, buyerName, orderId, product,
                            order.getQuantity(), unitPrice, amount, ref,
                            payMethod, buyerPhone, address, sellerName);

                        redirectMsg = "Order+confirmed!+Invoice+emailed+to+buyer.";
                    }
                }

                res.sendRedirect(req.getContextPath() + "/seller/dashboard?success=" + redirectMsg);

            } else {
                // SHIPPED / DELIVERED / CANCELLED
                orderDAO.updateStatus(orderId, newStatus);

                // If DELIVERED — send final delivery confirmation email
                if ("DELIVERED".equals(newStatus)) {
                    sendDeliveryConfirmAsync(orderId);
                }

                String emoji = switch (newStatus) {
                    case "SHIPPED"   -> "🚚+Order+marked+as+shipped!";
                    case "DELIVERED" -> "📦+Order+delivered!+Delivery+confirmation+emailed+to+buyer.";
                    case "CANCELLED" -> "❌+Order+cancelled.";
                    default          -> "Order+updated+to+" + newStatus;
                };
                res.sendRedirect(req.getContextPath() + "/seller/dashboard?success=" + emoji);
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    /** Send invoice email in background thread */
    private void sendInvoiceAsync(
            String email, String name, int orderId, String product,
            int qty, double unitPrice, double total, String ref,
            String method, String phone, String address, String seller) {

        if (email == null || email.trim().isEmpty()) {
            System.out.println("[Invoice] No email for order #" + orderId + " — skipping");
            return;
        }
        new Thread(() ->
            EmailService.sendInvoice(email, name, orderId, product, qty,
                unitPrice, total, ref, method, phone, address, seller)
        ).start();
    }

    /** Send delivery confirmation email */
    private void sendDeliveryConfirmAsync(int orderId) {
        new Thread(() -> {
            try {
                Order o = orderDAO.getById(orderId);
                if (o == null || o.getBuyerEmail() == null) return;
                EmailService.sendDeliveryConfirmation(
                    o.getBuyerEmail(), o.getBuyerName(), orderId,
                    o.getProductName(), o.getSellerName(),
                    o.getPaymentRef() != null ? o.getPaymentRef() : "IDK-" + orderId);
            } catch (Exception e) {
                System.err.println("[DeliveryEmail] Failed: " + e.getMessage());
            }
        }).start();
    }
}
