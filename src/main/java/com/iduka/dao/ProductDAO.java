package com.iduka.dao;
import com.iduka.model.Product;
import com.iduka.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ProductDAO {

    // Detect schema once - old DB used 'is_active', new uses 'active'
    private static String activeCol    = null;
    private static String stockCol     = null;
    private static String imageCol     = null;

    private void detectSchema(Connection c) throws SQLException {
        if (activeCol != null) return;
        ResultSetMetaData meta;
        try (Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM products LIMIT 0")) {
            meta = rs.getMetaData();
            activeCol = "active"; stockCol = "stock"; imageCol = "image_url"; // defaults
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                String col = meta.getColumnName(i).toLowerCase();
                if (col.equals("is_active"))      activeCol = "is_active";
                if (col.equals("stock_quantity"))  stockCol  = "stock_quantity";
                if (col.equals("image1"))          imageCol  = "image1";
            }
        }
    }

    private String activeFilter() { return (activeCol != null ? activeCol : "active") + "=1"; }

    public List<Product> getAllActive() throws SQLException {
        List<Product> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            String sql = "SELECT p.*,u.full_name as seller_name FROM products p " +
                         "JOIN users u ON p.seller_id=u.id " +
                         "WHERE p." + activeFilter() + " ORDER BY p.created_at DESC";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ResultSet rs = ps.executeQuery();
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Product> search(String keyword) throws SQLException {
        List<Product> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            String sql = "SELECT p.*,u.full_name as seller_name FROM products p " +
                         "JOIN users u ON p.seller_id=u.id " +
                         "WHERE p." + activeFilter() + " AND (p.name LIKE ? OR p.description LIKE ?) " +
                         "ORDER BY p.created_at DESC";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                String k = "%" + keyword + "%";
                ps.setString(1, k); ps.setString(2, k);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Product> getByCategory(int catId) throws SQLException {
        List<Product> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            String sql = "SELECT p.*,u.full_name as seller_name FROM products p " +
                         "JOIN users u ON p.seller_id=u.id " +
                         "WHERE p." + activeFilter() + " AND p.category_id=? " +
                         "ORDER BY p.created_at DESC";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, catId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    public List<Product> getBySeller(int sellerId) throws SQLException {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*,u.full_name as seller_name FROM products p " +
                     "JOIN users u ON p.seller_id=u.id " +
                     "WHERE p.seller_id=? ORDER BY p.created_at DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public Product findById(int id) throws SQLException {
        String sql = "SELECT p.*,u.full_name as seller_name FROM products p " +
                     "JOIN users u ON p.seller_id=u.id WHERE p.id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        }
    }

    public boolean addProduct(Product p) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            String sql = "INSERT INTO products(seller_id,category_id,name,description,price," +
                         stockCol + "," + imageCol + ") VALUES(?,?,?,?,?,?,?)";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, p.getSellerId()); ps.setInt(2, p.getCategoryId());
                ps.setString(3, p.getName()); ps.setString(4, p.getDescription());
                ps.setBigDecimal(5, p.getPrice()); ps.setInt(6, p.getStock());
                ps.setString(7, p.getImageUrl());
                return ps.executeUpdate() == 1;
            }
        }
    }

    public boolean updateProduct(Product p) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            String sql = "UPDATE products SET category_id=?,name=?,description=?,price=?," +
                         stockCol + "=?," + imageCol + "=?," + activeCol + "=? " +
                         "WHERE id=? AND seller_id=?";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, p.getCategoryId()); ps.setString(2, p.getName());
                ps.setString(3, p.getDescription()); ps.setBigDecimal(4, p.getPrice());
                ps.setInt(5, p.getStock()); ps.setString(6, p.getImageUrl());
                ps.setBoolean(7, p.isActive()); ps.setInt(8, p.getId()); ps.setInt(9, p.getSellerId());
                return ps.executeUpdate() == 1;
            }
        }
    }

    public boolean deleteProduct(int id, int sellerId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            detectSchema(c);
            String sql = "UPDATE products SET " + activeCol + "=0 WHERE id=? AND seller_id=?";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setInt(1, id); ps.setInt(2, sellerId);
                return ps.executeUpdate() == 1;
            }
        }
    }

    private Product map(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setSellerId(rs.getInt("seller_id"));
        p.setName(rs.getString("name"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getBigDecimal("price"));
        try { p.setCategoryId(rs.getInt("category_id")); }   catch (SQLException ignored) {}
        try { p.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignored) {}
        try { p.setSellerName(rs.getString("seller_name")); }  catch (SQLException ignored) {}

        // stock — try both column names
        try { p.setStock(rs.getInt("stock")); } catch (SQLException e) {
            try { p.setStock(rs.getInt("stock_quantity")); } catch (SQLException ignored) {}
        }
        // image — try both column names
        try { p.setImageUrl(rs.getString("image_url")); } catch (SQLException e) {
            try { p.setImageUrl(rs.getString("image1")); } catch (SQLException ignored) {}
        }
        // active — try both column names
        try { p.setActive(rs.getBoolean("active")); } catch (SQLException e) {
            try { p.setActive(rs.getBoolean("is_active")); } catch (SQLException ignored) { p.setActive(true); }
        }
        return p;
    }
}
