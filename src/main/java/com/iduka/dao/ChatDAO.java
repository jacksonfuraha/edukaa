package com.iduka.dao;
import com.iduka.model.ChatMessage;
import com.iduka.model.InboxItem;
import com.iduka.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ChatDAO {

    private final NotificationDAO notifDAO = new NotificationDAO();

    private static boolean colsChecked = false;
    private void ensureColumns(Connection c) {
        if (colsChecked) return;
        colsChecked = true;
        try { c.createStatement().executeUpdate(
            "ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS is_delivered BOOLEAN DEFAULT FALSE");
        } catch (SQLException ignored) {}
        try { c.createStatement().executeUpdate(
            "ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS is_seen BOOLEAN DEFAULT FALSE");
        } catch (SQLException ignored) {}
    }

    public boolean sendMessage(ChatMessage msg) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            String sql = "INSERT INTO chat_messages(sender_id,receiver_id,product_id,message,is_delivered) VALUES(?,?,?,?,TRUE)";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, msg.getSenderId()); ps.setInt(2, msg.getReceiverId());
                ps.setInt(3, msg.getProductId()); ps.setString(4, msg.getMessage());
                boolean ok = ps.executeUpdate() == 1;
                if (ok) {
                    String name = getSenderName(msg.getSenderId());
                    notifDAO.create(msg.getReceiverId(), "MESSAGE",
                        "\uD83D\uDCAC New message from " + name + ": " + truncate(msg.getMessage(), 40),
                        "/chat?userId=" + msg.getSenderId() + "&productId=" + msg.getProductId());
                }
                return ok;
            }
        }
    }

    public void markSeen(int viewerId, int otherId, int productId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE chat_messages SET is_seen=TRUE WHERE receiver_id=? AND sender_id=? AND product_id=? AND is_seen IS NOT TRUE")) {
                ps.setInt(1, viewerId); ps.setInt(2, otherId); ps.setInt(3, productId);
                ps.executeUpdate();
            }
        }
    }

    public List<ChatMessage> getConversation(int user1, int user2, int productId) throws SQLException {
        List<ChatMessage> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            String sql = "SELECT cm.*, u.full_name as sender_name FROM chat_messages cm " +
                         "JOIN users u ON cm.sender_id=u.id " +
                         "WHERE ((cm.sender_id=? AND cm.receiver_id=?) OR (cm.sender_id=? AND cm.receiver_id=?)) " +
                         "AND cm.product_id=? ORDER BY cm.sent_at ASC";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1,user1); ps.setInt(2,user2); ps.setInt(3,user2); ps.setInt(4,user1); ps.setInt(5,productId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) list.add(mapMsg(rs));
            }
        }
        return list;
    }

    /** Get inbox - NO GROUP BY, uses DISTINCT ON which is PostgreSQL native */
    public List<InboxItem> getInbox(int userId) throws SQLException {
        List<InboxItem> list = new ArrayList<>();
        // Step 1: get distinct conversations (other_id + product_id pairs)
        String convSql =
            "SELECT DISTINCT " +
            "  CASE WHEN sender_id=? THEN receiver_id ELSE sender_id END AS other_id, " +
            "  product_id " +
            "FROM chat_messages " +
            "WHERE sender_id=? OR receiver_id=?";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(convSql)) {
            ps.setInt(1, userId); ps.setInt(2, userId); ps.setInt(3, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int otherId   = rs.getInt("other_id");
                int productId = rs.getInt("product_id");

                // Step 2: get last message for this conversation
                String lastSql =
                    "SELECT cm.message, cm.sent_at, u.full_name AS other_name, p.name AS product_name " +
                    "FROM chat_messages cm " +
                    "JOIN users u ON u.id = ? " +
                    "LEFT JOIN products p ON p.id = ? " +
                    "WHERE ((cm.sender_id=? AND cm.receiver_id=?) OR (cm.sender_id=? AND cm.receiver_id=?)) " +
                    "AND cm.product_id=? " +
                    "ORDER BY cm.sent_at DESC LIMIT 1";

                try (PreparedStatement ps2 = c.prepareStatement(lastSql)) {
                    ps2.setInt(1, otherId);
                    ps2.setInt(2, productId);
                    ps2.setInt(3, userId);   ps2.setInt(4, otherId);
                    ps2.setInt(5, otherId);  ps2.setInt(6, userId);
                    ps2.setInt(7, productId);
                    ResultSet rs2 = ps2.executeQuery();

                    if (rs2.next()) {
                        // Step 3: count unread
                        int unread = 0;
                        String unreadSql =
                            "SELECT COUNT(*) FROM chat_messages " +
                            "WHERE sender_id=? AND receiver_id=? AND product_id=? AND is_seen IS NOT TRUE";
                        try (PreparedStatement ps3 = c.prepareStatement(unreadSql)) {
                            ps3.setInt(1, otherId); ps3.setInt(2, userId); ps3.setInt(3, productId);
                            ResultSet rs3 = ps3.executeQuery();
                            if (rs3.next()) unread = rs3.getInt(1);
                        }

                        InboxItem item = new InboxItem();
                        item.setOtherId(otherId);
                        item.setProductId(productId);
                        item.setOtherName(rs2.getString("other_name"));
                        item.setProductName(rs2.getString("product_name"));
                        item.setLastMessage(rs2.getString("message"));
                        item.setLastTime(rs2.getTimestamp("sent_at"));
                        item.setUnreadCount(unread);
                        list.add(item);
                    }
                }
            }
        }
        // Sort by last_time descending
        list.sort((a, b) -> b.getLastTime() != null && a.getLastTime() != null
            ? b.getLastTime().compareTo(a.getLastTime()) : 0);
        return list;
    }

    public int countUnread(int userId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT COUNT(*) FROM chat_messages WHERE receiver_id=? AND is_seen IS NOT TRUE")) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private String getSenderName(int senderId) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT full_name FROM users WHERE id=?")) {
            ps.setInt(1, senderId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getString(1) : "Someone";
        } catch (SQLException e) { return "Someone"; }
    }

    private String truncate(String s, int max) {
        if (s == null) return "";
        return s.length() > max ? s.substring(0, max) + "\u2026" : s;
    }

    private ChatMessage mapMsg(ResultSet rs) throws SQLException {
        ChatMessage m = new ChatMessage();
        m.setId(rs.getInt("id")); m.setSenderId(rs.getInt("sender_id"));
        m.setReceiverId(rs.getInt("receiver_id")); m.setProductId(rs.getInt("product_id"));
        m.setMessage(rs.getString("message")); m.setSentAt(rs.getTimestamp("sent_at"));
        try { m.setDelivered(rs.getBoolean("is_delivered")); } catch(SQLException ignored){}
        try { m.setSeen(rs.getBoolean("is_seen")); } catch(SQLException ignored){}
        try { m.setSenderName(rs.getString("sender_name")); } catch(SQLException ignored){}
        return m;
    }
}
