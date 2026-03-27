package com.iduka.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * IDUKA Email Service — sends beautiful HTML invoices via Gmail INSTANTLY.
 *
 * Set these in Render/Railway environment variables:
 *   GMAIL_USER     = your Gmail address  (e.g. iduka.store@gmail.com)
 *   GMAIL_PASSWORD = Gmail App Password  (16 characters, no spaces)
 *
 * How to get Gmail App Password:
 *   1. Go to myaccount.google.com → Security
 *   2. Turn ON 2-Step Verification
 *   3. Search "App passwords" → Create → choose "Mail"
 *   4. Copy the 16-character password → paste as GMAIL_PASSWORD
 */
public class EmailService {

    private static String getEnv(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.trim().isEmpty()) ? v.trim() : def;
    }

    private static Session buildSession() {
        String user = getEnv("GMAIL_USER",     "");
        String pass = getEnv("GMAIL_PASSWORD", "");
        Properties props = new Properties();
        props.put("mail.smtp.auth",               "true");
        props.put("mail.smtp.starttls.enable",    "true");
        props.put("mail.smtp.host",               "smtp.gmail.com");
        props.put("mail.smtp.port",               "587");
        props.put("mail.smtp.ssl.trust",          "smtp.gmail.com");
        props.put("mail.smtp.connectiontimeout",  "15000");
        props.put("mail.smtp.timeout",            "15000");
        return Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });
    }

    /** ── Main invoice email sent instantly when seller confirms order ── */
    public static void sendInvoice(
            String toEmail,   String buyerName,
            int    orderId,   String productName,
            int    quantity,  double unitPrice,
            double totalPaid, String paymentRef,
            String paymentMethod, String buyerPhone,
            String deliveryAddress, String sellerName) {

        String fromEmail = getEnv("GMAIL_USER", "");
        if (fromEmail.isEmpty()) {
            System.err.println("[Email] GMAIL_USER not set — invoice NOT sent for order #" + orderId);
            return;
        }
        try {
            Session session = buildSession();
            Message msg     = new MimeMessage(session);
            msg.setFrom(new InternetAddress(fromEmail, "IDUKA Marketplace"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("🧾 Invoice #" + orderId + " — Payment Confirmed | IDUKA");
            msg.setContent(buildInvoiceHtml(buyerName, orderId, productName, quantity,
                unitPrice, totalPaid, paymentRef, paymentMethod,
                buyerPhone, deliveryAddress, sellerName), "text/html; charset=utf-8");
            Transport.send(msg);
            System.out.println("[Email] ✅ Invoice sent to: " + toEmail + " for order #" + orderId);
        } catch (Exception e) {
            System.err.println("[Email] ❌ Invoice failed for order #" + orderId + ": " + e.getMessage());
        }
    }

    /** ── Delivery confirmation email when seller marks as DELIVERED ── */
    public static void sendDeliveryConfirmation(
            String toEmail, String buyerName,
            int orderId, String productName,
            String sellerName, String paymentRef) {

        String fromEmail = getEnv("GMAIL_USER", "");
        if (fromEmail.isEmpty()) return;
        try {
            Session session = buildSession();
            Message msg     = new MimeMessage(session);
            msg.setFrom(new InternetAddress(fromEmail, "IDUKA Marketplace"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("📦 Delivered! Order #" + orderId + " | IDUKA");
            msg.setContent(buildDeliveryHtml(buyerName, orderId, productName, sellerName, paymentRef),
                "text/html; charset=utf-8");
            Transport.send(msg);
            System.out.println("[Email] ✅ Delivery confirmation sent to: " + toEmail);
        } catch (Exception e) {
            System.err.println("[Email] ❌ Delivery email failed: " + e.getMessage());
        }
    }

    /** Legacy method kept for compatibility */
    public static void sendPayslip(
            String toEmail, String buyerName,
            int orderId, String productName,
            int quantity, double unitPrice, double totalPrice,
            String paymentRef, String paymentMethod,
            String deliveryAddress, String sellerName) {
        sendInvoice(toEmail, buyerName, orderId, productName, quantity,
                    unitPrice, totalPrice, paymentRef, paymentMethod,
                    "", deliveryAddress, sellerName);
    }

    // ──────────────────────────────────────────────────────────────────────
    //  HTML INVOICE BUILDER
    // ──────────────────────────────────────────────────────────────────────
    private static String buildInvoiceHtml(
            String buyerName, int orderId, String productName,
            int quantity, double unitPrice, double totalPaid,
            String paymentRef, String paymentMethod,
            String buyerPhone, String deliveryAddress, String sellerName) {

        NumberFormat nf  = NumberFormat.getIntegerInstance();
        String date      = new SimpleDateFormat("dd MMMM yyyy 'at' HH:mm").format(new Date());
        String invoiceNo = "INV-" + String.format("%06d", orderId);

        // Determine payment icon
        String payIcon = "💳";
        if (paymentMethod != null) {
            if (paymentMethod.contains("MTN"))    payIcon = "📱";
            if (paymentMethod.contains("Airtel")) payIcon = "📲";
            if (paymentMethod.contains("Bank"))   payIcon = "🏦";
            if (paymentMethod.contains("Cash"))   payIcon = "💵";
        }

        return "<!DOCTYPE html><html><head><meta charset='UTF-8'>" +
        "<meta name='viewport' content='width=device-width,initial-scale=1'>" +
        "<style>" +
        "*{margin:0;padding:0;box-sizing:border-box}" +
        "body{font-family:Arial,sans-serif;background:#f4f4f8;padding:20px}" +
        ".wrap{max-width:640px;margin:0 auto;border-radius:18px;overflow:hidden;box-shadow:0 8px 40px rgba(0,0,0,.15)}" +
        ".topbar{background:linear-gradient(135deg,#6c63ff,#a855f7);padding:30px;text-align:center}" +
        ".topbar h1{color:#fff;font-size:2rem;font-weight:900;letter-spacing:3px}" +
        ".topbar p{color:rgba(255,255,255,.8);font-size:.9rem;margin-top:4px}" +
        ".success-bar{background:#22c55e;padding:20px;text-align:center}" +
        ".success-bar .big{font-size:2.5rem}" +
        ".success-bar h2{color:#fff;font-size:1.2rem;font-weight:800;margin-top:6px}" +
        ".success-bar p{color:rgba(255,255,255,.85);font-size:.82rem;margin-top:3px}" +
        ".body{background:#fff;padding:32px}" +
        ".inv-row{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:24px;padding-bottom:20px;border-bottom:2px solid #f0eeff}" +
        ".inv-num{font-size:1.6rem;font-weight:900;color:#6c63ff}" +
        ".inv-meta{text-align:right;font-size:.82rem;color:#888;line-height:1.8}" +
        ".inv-meta strong{color:#444}" +
        ".greeting{font-size:.95rem;color:#444;line-height:1.7;margin-bottom:22px}" +
        "table{width:100%;border-collapse:collapse;margin-bottom:20px;border-radius:10px;overflow:hidden}" +
        "th{background:#6c63ff;color:#fff;padding:11px 14px;text-align:left;font-size:.82rem}" +
        "td{padding:12px 14px;border-bottom:1px solid #f5f5f5;font-size:.88rem;color:#444}" +
        "tr:last-child td{border:none}" +
        ".total-box{background:linear-gradient(135deg,#f0eeff,#faf5ff);border:2px solid #6c63ff;border-radius:14px;padding:20px 24px;display:flex;justify-content:space-between;align-items:center;margin:20px 0}" +
        ".total-label{font-size:1rem;font-weight:700;color:#6c63ff}" +
        ".total-amt{font-size:2rem;font-weight:900;color:#6c63ff}" +
        ".ref-box{background:#fefce8;border:2px solid #fbbf24;border-radius:12px;padding:18px;text-align:center;margin:20px 0}" +
        ".ref-label{font-size:.78rem;color:#92400e;font-weight:700;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px}" +
        ".ref-code{font-size:1.5rem;font-weight:900;color:#92400e;letter-spacing:4px;font-family:monospace}" +
        ".ref-note{font-size:.75rem;color:#a16207;margin-top:8px}" +
        ".details-title{font-size:.8rem;font-weight:700;color:#6c63ff;text-transform:uppercase;letter-spacing:1px;margin:22px 0 10px}" +
        ".details-grid{display:grid;grid-template-columns:1fr 1fr;border:1px solid #f0f0f0;border-radius:10px;overflow:hidden}" +
        ".ditem{padding:11px 14px;border-bottom:1px solid #f5f5f5}" +
        ".ditem:nth-child(odd){background:#fafafe}" +
        ".dlabel{font-size:.72rem;color:#999;margin-bottom:2px}" +
        ".dvalue{font-size:.87rem;font-weight:600;color:#333}" +
        ".steps{background:#f0fdf4;border:1px solid #86efac;border-radius:12px;padding:18px;margin:22px 0}" +
        ".step{display:flex;gap:10px;margin-bottom:10px;font-size:.87rem;color:#444;align-items:flex-start}" +
        ".step:last-child{margin:0}" +
        ".snum{background:#22c55e;color:#fff;border-radius:50%;width:22px;height:22px;display:flex;align-items:center;justify-content:center;font-size:.7rem;font-weight:800;flex-shrink:0;margin-top:1px}" +
        ".footer{background:#1a1a2e;padding:24px;text-align:center;color:rgba(255,255,255,.55);font-size:.76rem;line-height:1.9}" +
        ".footer strong{color:#a78bfa;font-size:.88rem;display:block;margin-bottom:4px}" +
        "@media(max-width:480px){.total-box{flex-direction:column;gap:8px;text-align:center}.inv-row{flex-direction:column;gap:8px}.inv-meta{text-align:left}.details-grid{grid-template-columns:1fr}}" +
        "</style></head><body><div class='wrap'>" +

        "<div class='topbar'><h1>🛍️ IDUKA</h1><p>Rwanda's Digital Marketplace</p></div>" +

        "<div class='success-bar'>" +
        "<div class='big'>✅</div>" +
        "<h2>Payment Confirmed & Invoice Ready!</h2>" +
        "<p>" + date + "</p>" +
        "</div>" +

        "<div class='body'>" +

        "<div class='inv-row'>" +
        "<div class='inv-num'>INVOICE</div>" +
        "<div class='inv-meta'>" +
        "<div><strong>Invoice No:</strong> " + invoiceNo + "</div>" +
        "<div><strong>Order No:</strong> #" + orderId + "</div>" +
        "<div><strong>Date:</strong> " + date + "</div>" +
        "</div></div>" +

        "<p class='greeting'>Dear <strong>" + buyerName + "</strong>,<br><br>" +
        "Thank you for shopping on <strong>IDUKA</strong>! 🎉 Your payment has been confirmed " +
        "and your order is now being processed. Please keep this invoice for your records.</p>" +

        "<table><thead><tr><th>Product</th><th>Seller</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr></thead>" +
        "<tbody><tr>" +
        "<td><strong>" + productName + "</strong></td>" +
        "<td>" + sellerName + "</td>" +
        "<td>" + quantity + "</td>" +
        "<td>RWF " + nf.format((long)unitPrice) + "</td>" +
        "<td><strong>RWF " + nf.format((long)totalPaid) + "</strong></td>" +
        "</tr></tbody></table>" +

        "<div class='total-box'>" +
        "<span class='total-label'>" + payIcon + " Total Amount Paid</span>" +
        "<span class='total-amt'>RWF " + nf.format((long)totalPaid) + "</span>" +
        "</div>" +

        "<div class='ref-box'>" +
        "<div class='ref-label'>🔖 Payment Reference Number</div>" +
        "<div class='ref-code'>" + paymentRef + "</div>" +
        "<div class='ref-note'>Save this reference. You will need it for any disputes or returns.</div>" +
        "</div>" +

        "<div class='details-title'>📋 Transaction Details</div>" +
        "<div class='details-grid'>" +
        "<div class='ditem'><div class='dlabel'>Payment Method</div><div class='dvalue'>" + payIcon + " " + paymentMethod + "</div></div>" +
        "<div class='ditem'><div class='dlabel'>Phone Number</div><div class='dvalue'>" + (buyerPhone != null && !buyerPhone.isEmpty() ? buyerPhone : "—") + "</div></div>" +
        "<div class='ditem'><div class='dlabel'>Delivery Address</div><div class='dvalue'>" + deliveryAddress + "</div></div>" +
        "<div class='ditem'><div class='dlabel'>Sold By</div><div class='dvalue'>" + sellerName + "</div></div>" +
        "</div>" +

        "<div class='details-title' style='margin-top:24px'>📦 What Happens Next?</div>" +
        "<div class='steps'>" +
        "<div class='step'><div class='snum'>1</div><div><strong>" + sellerName + "</strong> has been notified and will prepare your order shortly.</div></div>" +
        "<div class='step'><div class='snum'>2</div><div>You'll get an email notification when your order is <strong>shipped</strong>.</div></div>" +
        "<div class='step'><div class='snum'>3</div><div>Once you receive it, confirm delivery on IDUKA to complete the transaction.</div></div>" +
        "<div class='step'><div class='snum'>4</div><div>Have questions? Use the <strong>Chat</strong> feature on IDUKA to contact your seller.</div></div>" +
        "</div>" +

        "</div>" + // end body

        "<div class='footer'>" +
        "<strong>IDUKA Marketplace — Rwanda 🇷🇼</strong>" +
        "Empowering Rwanda's Youth Through Digital Commerce<br>" +
        "This is an automated invoice — do not reply to this email.<br>" +
        "For support, use the Chat feature on the IDUKA platform." +
        "</div>" +

        "</div></body></html>";
    }

    // ──────────────────────────────────────────────────────────────────────
    //  DELIVERY CONFIRMATION EMAIL
    // ──────────────────────────────────────────────────────────────────────
    private static String buildDeliveryHtml(
            String buyerName, int orderId, String productName,
            String sellerName, String paymentRef) {

        String date = new SimpleDateFormat("dd MMMM yyyy 'at' HH:mm").format(new Date());

        return "<!DOCTYPE html><html><head><meta charset='UTF-8'>" +
        "<style>" +
        "body{font-family:Arial,sans-serif;background:#f4f4f8;padding:20px}" +
        ".wrap{max-width:600px;margin:0 auto;border-radius:18px;overflow:hidden;box-shadow:0 8px 40px rgba(0,0,0,.12)}" +
        ".top{background:linear-gradient(135deg,#6c63ff,#a855f7);padding:28px;text-align:center}" +
        ".top h1{color:#fff;font-size:1.8rem;font-weight:900;letter-spacing:2px}" +
        ".banner{background:#6c63ff;padding:24px;text-align:center}" +
        ".banner .big{font-size:3rem}" +
        ".banner h2{color:#fff;font-size:1.3rem;margin-top:8px;font-weight:800}" +
        ".banner p{color:rgba(255,255,255,.85);font-size:.85rem;margin-top:4px}" +
        ".body{background:#fff;padding:32px;font-size:.92rem;color:#444;line-height:1.7}" +
        ".footer{background:#1a1a2e;padding:20px;text-align:center;color:rgba(255,255,255,.5);font-size:.75rem}" +
        ".footer strong{color:#a78bfa;display:block;margin-bottom:4px}" +
        "</style></head><body><div class='wrap'>" +
        "<div class='top'><h1>🛍️ IDUKA</h1></div>" +
        "<div class='banner'>" +
        "<div class='big'>📦</div>" +
        "<h2>Your Order Has Been Delivered!</h2>" +
        "<p>" + date + "</p>" +
        "</div>" +
        "<div class='body'>" +
        "<p>Dear <strong>" + buyerName + "</strong>,</p><br>" +
        "<p>Great news! Your order <strong>#" + orderId + "</strong> for <strong>" + productName + "</strong> " +
        "has been marked as <strong>delivered</strong> by <strong>" + sellerName + "</strong>.</p><br>" +
        "<p>If you have received your item, no further action is needed.</p><br>" +
        "<p>If you have <strong>not received</strong> your item, please contact your seller immediately " +
        "using the <strong>Chat</strong> feature on IDUKA.</p><br>" +
        "<p><strong>Payment Reference:</strong> " + paymentRef + "</p><br>" +
        "<p>Thank you for shopping on IDUKA! 🎉</p>" +
        "</div>" +
        "<div class='footer'><strong>IDUKA Marketplace — Rwanda 🇷🇼</strong>" +
        "Automated notification — do not reply to this email.</div>" +
        "</div></body></html>";
    }
}
