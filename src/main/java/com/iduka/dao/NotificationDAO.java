package com.iduka.dao;
import com.iduka.model.Notification;
import com.iduka.util.DBConnection;
import java.sql.*;
import java.util.*;

public class NotificationDAO {

    private static boolean tableCreated = false;

    private void ensureTable(Connection c) {
        if (tableCreated) return;
        try {
            c.createStatement().executeUpdate(
                "CREATE TABLE IF NOT EXISTS notifications (" +
                "  id SERIAL PRIMARY KEY," +
                "  user_id INT NOT NULL," +
                "  type VARCHAR(30) NOT NULL," +
                "  message TEXT NOT NULL," +
                "  link VARCHAR(255) DEFAULT ''," +
                "  is_read BOOLEAN DEFAULT FALSE," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")");
            tableCreated = true;
        } catch (SQLException e) {
            tableCreated = true;
            System.err.println("notifications table create warning: " + e.getMessage());
        }
    }

    public void create(int userId, String type, String message, String link) {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO notifications(user_id,type,message,link) VALUES(?,?,?,?)")) {
                ps.setInt(1, userId);
                ps.setString(2, type);
                ps.setString(3, message);
                ps.setString(4, link != null ? link : "");
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("Notification create error: " + e.getMessage());
        }
    }

    public List<Notification> getUnread(int userId) throws SQLException {
        List<Notification> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT * FROM notifications WHERE user_id=? AND is_read=FALSE ORDER BY created_at DESC LIMIT 20")) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public int countUnread(int userId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=FALSE")) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public void markAllRead(int userId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureTable(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "UPDATE notifications SET is_read=TRUE WHERE user_id=?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
        }
    }

    private Notification map(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setType(rs.getString("type"));
        n.setMessage(rs.getString("message"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }
}
