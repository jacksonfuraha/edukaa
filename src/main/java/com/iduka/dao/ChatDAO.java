package com.iduka.dao;
import com.iduka.model.ChatMessage;
import com.iduka.model.InboxItem;
import com.iduka.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ChatDAO {

    private final NotificationDAO notifDAO = new NotificationDAO();

    /** Ensure is_delivered / is_seen columns exist (safe to call every startup) */
    private static boolean colsChecked = false;
    private void ensureColumns(Connection c) {
        if (colsChecked) return;
        colsChecked = true;
        String[] alters = {
            "ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS is_delivered BOOLEAN DEFAULT FALSE",
            "ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS is_seen      BOOLEAN DEFAULT FALSE"
        };
        for (String sql : alters) {
            try { c.createStatement().executeUpdate(sql); } catch (SQLException ignored) {}
        }
    }

    /** Send a message — marks it as delivered immediately, notifies receiver */
    public boolean sendMessage(ChatMessage msg) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            String sql = "INSERT INTO chat_messages(sender_id,receiver_id,product_id,message,is_delivered) VALUES(?,?,?,?,TRUE)";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, msg.getSenderId()); ps.setInt(2, msg.getReceiverId());
                ps.setInt(3, msg.getProductId()); ps.setString(4, msg.getMessage());
                boolean ok = ps.executeUpdate() == 1;
                if (ok) {
                    String senderName = getSenderName(msg.getSenderId());
                    notifDAO.create(msg.getReceiverId(), "MESSAGE",
                        "\uD83D\uDCAC New message from " + senderName + ": " + truncate(msg.getMessage(), 40),
                        "/chat?userId=" + msg.getSenderId() + "&productId=" + msg.getProductId());
                }
                return ok;
            }
        }
    }

    /** Mark messages as SEEN when receiver opens conversation */
    public void markSeen(int viewerId, int otherId, int productId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            String sql = "UPDATE chat_messages SET is_seen=TRUE WHERE receiver_id=? AND sender_id=? AND product_id=? AND is_seen IS NOT TRUE";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, viewerId); ps.setInt(2, otherId); ps.setInt(3, productId);
                ps.executeUpdate();
            }
        }
    }

    /** Get conversation messages */
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

    /**
     * Get inbox: one row per unique (other_user, product) conversation,
     * with the other person's name, product name, last message and time.
     * Works for BOTH sender and receiver sides.
     */
    public List<InboxItem> getInbox(int userId) throws SQLException {
        List<InboxItem> list = new ArrayList<>();
        // For each conversation the user participated in (as sender OR receiver),
        // return the most recent message summary.
        String sql =
            "SELECT " +
            "  CASE WHEN cm.sender_id=? THEN cm.receiver_id ELSE cm.sender_id END AS other_id," +
            "  cm.product_id," +
            "  u.full_name  AS other_name," +
            "  p.name       AS product_name," +
            "  cm.message   AS last_message," +
            "  cm.sent_at   AS last_time," +
            "  SUM(CASE WHEN cm.receiver_id=? AND cm.is_seen IS NOT TRUE THEN 1 ELSE 0 END) AS unread_count " +
            "FROM chat_messages cm " +
            "JOIN users u ON u.id = CASE WHEN cm.sender_id=? THEN cm.receiver_id ELSE cm.sender_id END " +
            "LEFT JOIN products p ON p.id = cm.product_id " +
            "WHERE cm.sender_id=? OR cm.receiver_id=? " +
            "GROUP BY other_id, cm.product_id " +
            "ORDER BY last_time DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId); ps.setInt(2, userId);
            ps.setInt(3, userId); ps.setInt(4, userId); ps.setInt(5, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InboxItem item = new InboxItem();
                item.setOtherId(rs.getInt("other_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setOtherName(rs.getString("other_name"));
                item.setProductName(rs.getString("product_name"));
                item.setLastMessage(rs.getString("last_message"));
                item.setLastTime(rs.getTimestamp("last_time"));
                item.setUnreadCount(rs.getInt("unread_count"));
                list.add(item);
            }
        }
        return list;
    }

    /** Count unread messages received by userId */
    public int countUnread(int userId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureColumns(c);
            String sql = "SELECT COUNT(*) FROM chat_messages WHERE receiver_id=? AND is_seen IS NOT TRUE";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
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
