package com.iduka.dao;

import com.iduka.model.Order;
import com.iduka.util.DBConnection;
import com.iduka.util.EmailService;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class OrderDAO {

    private final NotificationDAO notifDAO = new NotificationDAO();

    public int placeOrder(Order o) throws SQLException {
        if (o.getSellerId() == 0) {
            try (Connection c = DBConnection.getConnection();
                 PreparedStatement ps = c.prepareStatement("SELECT seller_id,price FROM products WHERE id=?")) {
                ps.setInt(1, o.getProductId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    o.setSellerId(rs.getInt("seller_id"));
                    if (o.getUnitPrice() == null) o.setUnitPrice(rs.getBigDecimal("price"));
                }
            }
        }
        String sql = "INSERT INTO orders(buyer_id,product_id,quantity,total_price,delivery_address,status) VALUES(?,?,?,?,?,?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, o.getBuyerId()); ps.setInt(2, o.getProductId());
            ps.setInt(3, o.getQuantity()); ps.setBigDecimal(4, o.getTotalPrice());
            ps.setString(5, o.getDeliveryAddress()); ps.setString(6, "PENDING");
            ps.executeUpdate();
            trySetExtraOrderColumns(c, -1, o); // will use last insert id below
            ResultSet keys = ps.getGeneratedKeys();
            int newId = keys.next() ? keys.getInt(1) : -1;
            if (newId > 0) {
                trySetExtraOrderColumns2(c, newId, o);
                // Reduce stock
                try (PreparedStatement ps2 = c.prepareStatement(
                        "UPDATE products SET stock=stock-? WHERE id=? AND stock>=?")) {
                    ps2.setInt(1,o.getQuantity()); ps2.setInt(2,o.getProductId()); ps2.setInt(3,o.getQuantity());
                    ps2.executeUpdate();
                }
                // Notify seller
                String productName = o.getProductName() != null ? o.getProductName() : "your product";
                String buyerName   = o.getBuyerName()   != null ? o.getBuyerName()   : "A buyer";
                notifDAO.create(o.getSellerId(), "ORDER",
                    "🛒 " + buyerName + " placed an order for " + productName + " (Qty: " + o.getQuantity() + ")",
                    "/seller/dashboard");
            }
            return newId;
        }
    }

    private void trySetExtraOrderColumns2(Connection c, int orderId, Order o) {
        // Try with buyer_phone column
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE orders SET seller_id=?,unit_price=?,payment_method=?,payment_status=?,buyer_phone=? WHERE id=?")) {
            ps.setInt(1, o.getSellerId());
            ps.setBigDecimal(2, o.getUnitPrice() != null ? o.getUnitPrice() : o.getTotalPrice());
            ps.setString(3, o.getPaymentMethod() != null ? o.getPaymentMethod() : "Mobile Money");
            ps.setString(4, "UNPAID");
            ps.setString(5, o.getBuyerPhone());
            ps.setInt(6, orderId);
            ps.executeUpdate();
            return;
        } catch (SQLException ignored) {}
        // Fallback without buyer_phone
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE orders SET seller_id=?,unit_price=?,payment_method=?,payment_status=? WHERE id=?")) {
            ps.setInt(1, o.getSellerId());
            ps.setBigDecimal(2, o.getUnitPrice() != null ? o.getUnitPrice() : o.getTotalPrice());
            ps.setString(3, o.getPaymentMethod() != null ? o.getPaymentMethod() : "Mobile Money");
            ps.setString(4, "UNPAID");
            ps.setInt(5, orderId);
            ps.executeUpdate();
        } catch (SQLException ignored) {}
    }

    private void trySetExtraOrderColumns(Connection c, int orderId, Order o) {}

    public List<Order> getByBuyer(int buyerId) throws SQLException {
        return query("WHERE p.seller_id=p.seller_id AND o.buyer_id=?", buyerId);
    }
    public List<Order> getBySeller(int sellerId) throws SQLException {
        return query("WHERE p.seller_id=?", sellerId);
    }
    public Order getById(int orderId) throws SQLException {
        List<Order> list = queryWhere("WHERE o.id=?", orderId);
        return list.isEmpty() ? null : list.get(0);
    }

    private List<Order> query(String where, int param) throws SQLException {
        return queryWhere(where, param);
    }
    private List<Order> queryWhere(String where, int param) throws SQLException {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.full_name as buyer_name, u.email as buyer_email, " +
                     "COALESCE(o.buyer_phone, u.phone) as buyer_phone_final, u.phone as user_phone, " +
                     "p.name as product_name, p.price as unit_price_col, p.seller_id as p_seller_id, " +
                     "s.full_name as seller_name " +
                     "FROM orders o " +
                     "JOIN users u ON o.buyer_id=u.id " +
                     "JOIN products p ON o.product_id=p.id " +
                     "JOIN users s ON p.seller_id=s.id " + where + " ORDER BY o.created_at DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, param);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public boolean updateStatus(int orderId, String newStatus) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            if ("CONFIRMED".equals(newStatus)) {
                String payRef = "IDK-" + System.currentTimeMillis();
                boolean updated = false;
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE orders SET status=?,payment_status='PAID',payment_ref=? WHERE id=?")) {
                    ps.setString(1, newStatus); ps.setString(2, payRef); ps.setInt(3, orderId);
                    updated = ps.executeUpdate() == 1;
                } catch (SQLException e) {
                    try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET status=? WHERE id=?")) {
                        ps.setString(1, newStatus); ps.setInt(2, orderId);
                        updated = ps.executeUpdate() == 1;
                    }
                }
                if (updated) {
                    notifyBuyerStatusChange(orderId, newStatus);
                    triggerPayslipEmail(orderId, payRef);
                }
                return updated;
            } else {
                try (PreparedStatement ps = c.prepareStatement("UPDATE orders SET status=? WHERE id=?")) {
                    ps.setString(1, newStatus); ps.setInt(2, orderId);
                    boolean ok = ps.executeUpdate() == 1;
                    if (ok) notifyBuyerStatusChange(orderId, newStatus);
                    return ok;
                }
            }
        }
    }

    private void notifyBuyerStatusChange(int orderId, String newStatus) {
        new Thread(() -> {
            try {
                Order o = getById(orderId);
                if (o == null) return;
                String emoji = switch (newStatus) {
                    case "CONFIRMED" -> "✅";
                    case "SHIPPED"   -> "🚚";
                    case "DELIVERED" -> "📦";
                    case "CANCELLED" -> "❌";
                    default          -> "📋";
                };
                notifDAO.create(o.getBuyerId(), "ORDER_STATUS",
                    emoji + " Your order for " + o.getProductName() + " is now " + newStatus,
                    "/buyer/order");
            } catch (Exception e) { System.err.println("Status notify failed: " + e.getMessage()); }
        }).start();
    }

    private void triggerPayslipEmail(int orderId, String payRef) {
        new Thread(() -> {
            try {
                Order o = getById(orderId);
                if (o != null && o.getBuyerEmail() != null && !o.getBuyerEmail().isEmpty()) {
                    EmailService.sendPayslip(o.getBuyerEmail(), o.getBuyerName(), o.getId(),
                        o.getProductName(), o.getQuantity(),
                        o.getUnitPrice()  != null ? o.getUnitPrice().doubleValue()  : 0,
                        o.getTotalPrice() != null ? o.getTotalPrice().doubleValue() : 0,
                        payRef, o.getPaymentMethod() != null ? o.getPaymentMethod() : "Mobile Money",
                        o.getDeliveryAddress(), o.getSellerName());
                    try (Connection c2 = DBConnection.getConnection();
                         PreparedStatement ps2 = c2.prepareStatement("UPDATE orders SET payslip_sent=1 WHERE id=?")) {
                        ps2.setInt(1, orderId); ps2.executeUpdate();
                    } catch (SQLException ignored) {}
                }
            } catch (Exception e) { System.err.println("Payslip email failed: " + e.getMessage()); }
        }).start();
    }

    private Order map(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id")); o.setBuyerId(rs.getInt("buyer_id")); o.setProductId(rs.getInt("product_id"));
        o.setQuantity(rs.getInt("quantity")); o.setTotalPrice(rs.getBigDecimal("total_price"));
        o.setStatus(rs.getString("status"));
        try { o.setDeliveryAddress(rs.getString("delivery_address")); } catch(SQLException ignored){}
        try { o.setCreatedAt(rs.getTimestamp("created_at")); } catch(SQLException ignored){}
        try { o.setPaymentStatus(rs.getString("payment_status")); } catch(SQLException ignored){}
        try { o.setPaymentMethod(rs.getString("payment_method")); } catch(SQLException ignored){}
        try { o.setPaymentRef(rs.getString("payment_ref")); }       catch(SQLException ignored){}
        try { o.setPayslipSent(rs.getBoolean("payslip_sent")); }    catch(SQLException ignored){}
        try { o.setBuyerName(rs.getString("buyer_name")); }         catch(SQLException ignored){}
        try { o.setBuyerEmail(rs.getString("buyer_email")); }       catch(SQLException ignored){}
        try { 
                String bp = rs.getString("buyer_phone_final");
                if (bp == null || bp.isEmpty()) bp = rs.getString("user_phone");
                o.setBuyerPhone(bp);
            } catch(SQLException ignored){}
        try { o.setProductName(rs.getString("product_name")); }     catch(SQLException ignored){}
        try { o.setSellerName(rs.getString("seller_name")); }       catch(SQLException ignored){}
        try { o.setSellerId(rs.getInt("p_seller_id")); }            catch(SQLException ignored){}
        try { o.setUnitPrice(rs.getBigDecimal("unit_price_col")); } catch(SQLException ignored){}
        try { BigDecimal up = rs.getBigDecimal("unit_price"); if(up!=null) o.setUnitPrice(up); } catch(SQLException ignored){}
        return o;
    }

    /** Update payment reference, network and request status after MoMo call */
    public void updatePaymentRef(int orderId, String ref, String network, String requestStatus) {
        new Thread(() -> {
            try (Connection c = DBConnection.getConnection()) {
                // Try with all columns first
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE orders SET payment_ref=?, payment_method=?, payment_status='PAYMENT_SENT' WHERE id=?")) {
                    ps.setString(1, ref);
                    ps.setString(2, network + " MoMo");
                    ps.setInt(3, orderId);
                    ps.executeUpdate();
                } catch (SQLException e) {
                    // Fallback - just update ref
                    try (PreparedStatement ps = c.prepareStatement(
                            "UPDATE orders SET payment_ref=? WHERE id=?")) {
                        ps.setString(1, ref);
                        ps.setInt(2, orderId);
                        ps.executeUpdate();
                    } catch (SQLException ignored) {}
                }
            } catch (SQLException e) {
                System.err.println("updatePaymentRef error: " + e.getMessage());
            }
        }).start();
    }

}