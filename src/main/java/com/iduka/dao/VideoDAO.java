package com.iduka.dao;

import com.iduka.model.ProductVideo;
import com.iduka.model.VideoComment;
import com.iduka.util.DBConnection;
import java.sql.*;
import java.util.*;

public class VideoDAO {

    private final NotificationDAO notifDAO = new NotificationDAO();

    // Schema flags
    private static String  videoCol      = null;
    private static boolean hasActive     = false;
    private static boolean hasLikes      = false;
    private static boolean hasThumbnail  = false;
    private static boolean schemaChecked = false;
    private static boolean tablesCreated = false;

    // ── Ensure extra tables exist (called once) ──────────────────────────
    private void ensureTables(Connection c) {
        if (tablesCreated) return;
        tablesCreated = true;
        // video_likes
        try {
            c.createStatement().executeUpdate(
                "CREATE TABLE IF NOT EXISTS video_likes (" +
                "  id         SERIAL PRIMARY KEY," +
                "  video_id   INT NOT NULL," +
                "  user_id    INT NOT NULL," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "  UNIQUE (video_id, user_id)" +
                ")");
        } catch (SQLException e) {
            System.err.println("video_likes table warning: " + e.getMessage());
        }
        // video_comments (may already exist from DBInitializer)
        try {
            c.createStatement().executeUpdate(
                "CREATE TABLE IF NOT EXISTS video_comments (" +
                "  id         SERIAL PRIMARY KEY," +
                "  video_id   INT NOT NULL," +
                "  user_id    INT NOT NULL," +
                "  comment    TEXT NOT NULL," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")");
        } catch (SQLException e) {
            System.err.println("video_comments table warning: " + e.getMessage());
        }
    }

    // ── Schema detection — fixed for PostgreSQL ──────────────────────────
    private void detectSchema(Connection c) throws SQLException {
        if (schemaChecked) return;
        // PostgreSQL schema is fixed — use known column names from DBInitializer
        videoCol     = "video_url";
        hasActive    = true;
        hasLikes     = true;
        hasThumbnail = true;
        schemaChecked = true;
    }

    // ── Get all videos ───────────────────────────────────────────────────
    public List<ProductVideo> getAll() throws SQLException {
        List<ProductVideo> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            ensureTables(c);
            String where = hasActive ? " WHERE pv.active=TRUE " : " ";
            String sql = "SELECT pv.*, u.full_name AS seller_name " +
                         "FROM product_videos pv JOIN users u ON pv.seller_id=u.id" +
                         where + "ORDER BY pv.created_at DESC";
            try (PreparedStatement ps = c.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ── Get by seller (with comment count) ──────────────────────────────
    public List<ProductVideo> getBySeller(int sellerId) throws SQLException {
        List<ProductVideo> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            ensureTables(c);
            // Safe: video_comments table is guaranteed to exist now
            String sql = "SELECT pv.*, u.full_name AS seller_name, " +
                         "(SELECT COUNT(*) FROM video_comments vc WHERE vc.video_id=pv.id) AS comment_count " +
                         "FROM product_videos pv JOIN users u ON pv.seller_id=u.id " +
                         "WHERE pv.seller_id=? ORDER BY pv.created_at DESC";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, sellerId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ── Add video ────────────────────────────────────────────────────────
    public boolean addVideo(ProductVideo v) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            ensureTables(c);
            StringBuilder cols = new StringBuilder("seller_id,product_id,title,").append(videoCol);
            StringBuilder vals = new StringBuilder("?,?,?,?");
            if (hasThumbnail) { cols.append(",thumbnail_url"); vals.append(",?"); }
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO product_videos(" + cols + ") VALUES(" + vals + ")")) {
                ps.setInt(1, v.getSellerId());
                ps.setInt(2, v.getProductId());
                ps.setString(3, v.getTitle());
                ps.setString(4, v.getVideoUrl());
                if (hasThumbnail) ps.setString(5, v.getThumbnailUrl() != null ? v.getThumbnailUrl() : "");
                return ps.executeUpdate() == 1;
            }
        }
    }

    // ── Toggle like ──────────────────────────────────────────────────────
    public int toggleLike(int videoId, int userId) throws SQLException {
        if (userId <= 0) return getLikeCount(videoId);
        try (Connection c = DBConnection.getConnection()) {
            ensureTables(c);
            boolean alreadyLiked = false;
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT id FROM video_likes WHERE video_id=? AND user_id=?")) {
                ps.setInt(1, videoId); ps.setInt(2, userId);
                alreadyLiked = ps.executeQuery().next();
            }
            if (alreadyLiked) {
                try (PreparedStatement ps = c.prepareStatement(
                        "DELETE FROM video_likes WHERE video_id=? AND user_id=?")) {
                    ps.setInt(1, videoId); ps.setInt(2, userId); ps.executeUpdate();
                }
                if (hasLikes) try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE product_videos SET likes=GREATEST(0,likes-1) WHERE id=?")) {
                    ps.setInt(1, videoId); ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO video_likes(video_id,user_id) VALUES(?,?) ON CONFLICT DO NOTHING")) {
                    ps.setInt(1, videoId); ps.setInt(2, userId); ps.executeUpdate();
                }
                if (hasLikes) try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE product_videos SET likes=likes+1 WHERE id=?")) {
                    ps.setInt(1, videoId); ps.executeUpdate();
                }
                notifyLike(c, videoId, userId);
            }
            return getLikeCountConn(c, videoId);
        }
    }

    public boolean isLiked(int videoId, int userId) throws SQLException {
        if (userId <= 0) return false;
        try (Connection c = DBConnection.getConnection()) {
            ensureTables(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT id FROM video_likes WHERE video_id=? AND user_id=?")) {
                ps.setInt(1, videoId); ps.setInt(2, userId);
                return ps.executeQuery().next();
            }
        }
    }

    private int getLikeCount(int videoId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) { return getLikeCountConn(c, videoId); }
    }
    private int getLikeCountConn(Connection c, int videoId) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*) FROM video_likes WHERE video_id=?")) {
            ps.setInt(1, videoId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Comments ─────────────────────────────────────────────────────────
    public List<VideoComment> getComments(int videoId) throws SQLException {
        List<VideoComment> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            ensureTables(c);
            String sql = "SELECT vc.*, u.full_name AS user_name, u.avatar_url " +
                         "FROM video_comments vc JOIN users u ON vc.user_id=u.id " +
                         "WHERE vc.video_id=? ORDER BY vc.created_at ASC";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, videoId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    VideoComment cm = new VideoComment();
                    cm.setId(rs.getInt("id"));
                    cm.setVideoId(videoId);
                    cm.setUserId(rs.getInt("user_id"));
                    cm.setComment(rs.getString("comment"));
                    cm.setUserName(rs.getString("user_name"));
                    try { cm.setAvatarUrl(rs.getString("avatar_url")); } catch (SQLException ignored) {}
                    cm.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(cm);
                }
            }
        }
        return list;
    }

    public VideoComment addComment(int videoId, int userId, String text) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            ensureTables(c);
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO video_comments(video_id,user_id,comment) VALUES(?,?,?) RETURNING id")) {
                ps.setInt(1, videoId); ps.setInt(2, userId); ps.setString(3, text);
                ResultSet keys = ps.executeQuery();
                int newId = keys.next() ? keys.getInt(1) : -1;
                notifyComment(c, videoId, userId, text);
                try (PreparedStatement ps2 = c.prepareStatement(
                        "SELECT vc.*, u.full_name AS user_name, u.avatar_url " +
                        "FROM video_comments vc JOIN users u ON vc.user_id=u.id WHERE vc.id=?")) {
                    ps2.setInt(1, newId);
                    ResultSet rs = ps2.executeQuery();
                    if (rs.next()) {
                        VideoComment cm = new VideoComment();
                        cm.setId(rs.getInt("id")); cm.setVideoId(videoId); cm.setUserId(userId);
                        cm.setComment(rs.getString("comment")); cm.setUserName(rs.getString("user_name"));
                        try { cm.setAvatarUrl(rs.getString("avatar_url")); } catch (SQLException ignored) {}
                        cm.setCreatedAt(rs.getTimestamp("created_at"));
                        return cm;
                    }
                }
            }
        }
        return null;
    }

    // ── Notifications ────────────────────────────────────────────────────
    private void notifyLike(Connection c, int videoId, int likerId) {
        try {
            int sellerId = 0; String title = "your video"; String likerName = "Someone";
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT pv.seller_id, pv.title, u.full_name " +
                    "FROM product_videos pv JOIN users u ON u.id=? WHERE pv.id=?")) {
                ps.setInt(1, likerId); ps.setInt(2, videoId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) { sellerId=rs.getInt("seller_id"); title=rs.getString("title"); likerName=rs.getString("full_name"); }
            }
            if (sellerId > 0 && sellerId != likerId)
                notifDAO.create(sellerId, "LIKE", "❤️ " + likerName + " liked: " + trunc(title,35), "/videos");
        } catch (Exception e) { System.err.println("notifyLike: " + e.getMessage()); }
    }

    private void notifyComment(Connection c, int videoId, int commenterId, String text) {
        try {
            int sellerId = 0; String title = "your video"; String name = "Someone";
            try (PreparedStatement ps = c.prepareStatement(
                    "SELECT pv.seller_id, pv.title, u.full_name " +
                    "FROM product_videos pv JOIN users u ON u.id=? WHERE pv.id=?")) {
                ps.setInt(1, commenterId); ps.setInt(2, videoId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) { sellerId=rs.getInt("seller_id"); title=rs.getString("title"); name=rs.getString("full_name"); }
            }
            if (sellerId > 0 && sellerId != commenterId)
                notifDAO.create(sellerId, "COMMENT", "💬 " + name + " commented on \"" + trunc(title,25) + "\": " + trunc(text,35), "/videos");
        } catch (Exception e) { System.err.println("notifyComment: " + e.getMessage()); }
    }

    private String trunc(String s, int max) {
        if (s == null) return ""; return s.length() > max ? s.substring(0,max)+"…" : s;
    }

    private ProductVideo map(ResultSet rs) throws SQLException {
        ProductVideo v = new ProductVideo();
        v.setId(rs.getInt("id")); v.setSellerId(rs.getInt("seller_id")); v.setTitle(rs.getString("title"));
        try { v.setProductId(rs.getInt("product_id")); }      catch (SQLException ignored) {}
        try { v.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignored) {}
        try { v.setSellerName(rs.getString("seller_name")); }  catch (SQLException ignored) {}
        try { v.setVideoUrl(rs.getString("video_url")); }      catch (SQLException e) {
            try { v.setVideoUrl(rs.getString("video_path")); } catch (SQLException ignored) {} }
        try { v.setThumbnailUrl(rs.getString("thumbnail_url")); } catch (SQLException ignored) {}
        try { v.setLikes(rs.getInt("likes")); }                catch (SQLException ignored) {}
        try { v.setCommentCount(rs.getInt("comment_count")); } catch (SQLException ignored) {}
        return v;
    }
}
