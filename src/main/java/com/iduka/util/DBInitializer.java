package com.iduka.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;

/**
 * Runs on startup - creates all tables if they don't exist.
 * PostgreSQL version - no manual SQL needed on Render.
 */
@WebListener
public class DBInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("=== IDUKA: Initializing PostgreSQL tables ===");
        try (Connection c = DBConnection.getConnection()) {
            createTables(c);
            seedCategories(c);
            System.out.println("=== IDUKA: Database ready ===");
        } catch (Exception e) {
            System.err.println("=== IDUKA DB init warning: " + e.getMessage() + " ===");
        }
    }

    private void createTables(Connection c) throws SQLException {
        String[] ddl = {
            // ── users ──────────────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS users (" +
            "  id          SERIAL PRIMARY KEY," +
            "  full_name   VARCHAR(100) NOT NULL," +
            "  email       VARCHAR(100) UNIQUE NOT NULL," +
            "  phone       VARCHAR(20)," +
            "  password    VARCHAR(255) NOT NULL," +
            "  role        VARCHAR(10)  DEFAULT 'BUYER' CHECK (role IN ('BUYER','SELLER','ADMIN'))," +
            "  country     VARCHAR(100) DEFAULT 'Rwanda'," +
            "  province    VARCHAR(100), district VARCHAR(100)," +
            "  sector      VARCHAR(100), cell     VARCHAR(100), village VARCHAR(100)," +
            "  avatar_url  VARCHAR(255), id_number VARCHAR(30)," +
            "  tin_number  VARCHAR(20),  id_card_url VARCHAR(255)," +
            "  verified    BOOLEAN DEFAULT FALSE," +
            "  active      BOOLEAN DEFAULT TRUE," +
            "  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            // ── categories ─────────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS categories (" +
            "  id         SERIAL PRIMARY KEY," +
            "  name       VARCHAR(100) NOT NULL," +
            "  icon_class VARCHAR(80)  DEFAULT 'fas fa-tag')",

            // ── products ───────────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS products (" +
            "  id          SERIAL PRIMARY KEY," +
            "  seller_id   INT NOT NULL," +
            "  category_id INT," +
            "  name        VARCHAR(200) NOT NULL," +
            "  description TEXT," +
            "  price       DECIMAL(10,2) NOT NULL," +
            "  stock       INT DEFAULT 0," +
            "  image_url   VARCHAR(255)," +
            "  active      BOOLEAN DEFAULT TRUE," +
            "  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "  FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE)",

            // ── product_videos ─────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS product_videos (" +
            "  id            SERIAL PRIMARY KEY," +
            "  seller_id     INT NOT NULL," +
            "  product_id    INT," +
            "  title         VARCHAR(200)," +
            "  video_url     VARCHAR(255) NOT NULL," +
            "  thumbnail_url VARCHAR(255)," +
            "  likes         INT DEFAULT 0," +
            "  active        BOOLEAN DEFAULT TRUE," +
            "  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "  FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE)",

            // ── video_likes ────────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS video_likes (" +
            "  id         SERIAL PRIMARY KEY," +
            "  video_id   INT NOT NULL," +
            "  user_id    INT NOT NULL," +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "  UNIQUE (video_id, user_id))",

            // ── video_comments ─────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS video_comments (" +
            "  id         SERIAL PRIMARY KEY," +
            "  video_id   INT NOT NULL," +
            "  user_id    INT NOT NULL," +
            "  comment    TEXT NOT NULL," +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",

            // ── orders ─────────────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS orders (" +
            "  id               SERIAL PRIMARY KEY," +
            "  buyer_id         INT NOT NULL," +
            "  seller_id        INT DEFAULT 0," +
            "  product_id       INT NOT NULL," +
            "  quantity         INT DEFAULT 1," +
            "  unit_price       DECIMAL(10,2)," +
            "  total_price      DECIMAL(10,2) NOT NULL," +
            "  delivery_address TEXT," +
            "  status           VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED'))," +
            "  payment_status   VARCHAR(50)  DEFAULT 'UNPAID'," +
            "  payment_method   VARCHAR(100) DEFAULT 'Mobile Money'," +
            "  payment_ref      VARCHAR(100)," +
            "  buyer_phone      VARCHAR(20)," +
            "  payslip_sent     BOOLEAN DEFAULT FALSE," +
            "  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "  FOREIGN KEY (buyer_id)   REFERENCES users(id)," +
            "  FOREIGN KEY (product_id) REFERENCES products(id))",

            // ── chat_messages ──────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS chat_messages (" +
            "  id           SERIAL PRIMARY KEY," +
            "  sender_id    INT NOT NULL," +
            "  receiver_id  INT NOT NULL," +
            "  product_id   INT DEFAULT 0," +
            "  message      TEXT NOT NULL," +
            "  is_delivered BOOLEAN DEFAULT FALSE," +
            "  is_seen      BOOLEAN DEFAULT FALSE," +
            "  sent_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "  FOREIGN KEY (sender_id)   REFERENCES users(id)," +
            "  FOREIGN KEY (receiver_id) REFERENCES users(id))",

            // ── notifications ──────────────────────────────────────────────
            "CREATE TABLE IF NOT EXISTS notifications (" +
            "  id         SERIAL PRIMARY KEY," +
            "  user_id    INT NOT NULL," +
            "  type       VARCHAR(30)  NOT NULL," +
            "  message    TEXT         NOT NULL," +
            "  link       VARCHAR(255) DEFAULT ''," +
            "  is_read    BOOLEAN DEFAULT FALSE," +
            "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
            "  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)"
        };

        for (String sql : ddl) {
            try { c.createStatement().executeUpdate(sql); }
            catch (SQLException e) {
                System.err.println("DDL warning: " + e.getMessage());
            }
        }
    }

    private void seedCategories(Connection c) throws SQLException {
        ResultSet rs = c.createStatement().executeQuery("SELECT COUNT(*) FROM categories");
        rs.next();
        if (rs.getInt(1) > 0) return;
        String sql = "INSERT INTO categories(name,icon_class) VALUES(?,?)";
        String[][] cats = {
            {"Electronics","fas fa-laptop"},{"Fashion","fas fa-tshirt"},
            {"Food & Drinks","fas fa-utensils"},{"Home & Garden","fas fa-home"},
            {"Health & Beauty","fas fa-spa"},{"Agriculture","fas fa-seedling"},
            {"Services","fas fa-tools"},{"Vehicles","fas fa-car"},
            {"Education","fas fa-book"},{"Other","fas fa-box"}
        };
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            for (String[] cat : cats) {
                ps.setString(1, cat[0]); ps.setString(2, cat[1]);
                ps.executeUpdate();
            }
        }
        System.out.println("=== IDUKA: Categories seeded ===");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {}
}
