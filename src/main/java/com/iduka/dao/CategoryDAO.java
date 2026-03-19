package com.iduka.dao;
import com.iduka.model.Category;
import com.iduka.util.DBConnection;
import java.sql.*;
import java.util.*;

public class CategoryDAO {
    public List<Category> getAll() throws SQLException {
        List<Category> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); Statement st = c.createStatement()) {
            ResultSet rs = st.executeQuery("SELECT * FROM categories ORDER BY name");
            ResultSetMetaData meta = rs.getMetaData();
            // Find which icon column name exists
            boolean hasIconClass = false, hasIcon = false;
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                String col = meta.getColumnName(i).toLowerCase();
                if (col.equals("icon_class")) hasIconClass = true;
                if (col.equals("icon"))       hasIcon = true;
            }
            while (rs.next()) {
                Category cat = new Category();
                cat.setId(rs.getInt("id"));
                cat.setName(rs.getString("name"));
                String icon = "fas fa-tag"; // default
                if (hasIconClass) {
                    String v = rs.getString("icon_class");
                    if (v != null && !v.isEmpty()) icon = v;
                } else if (hasIcon) {
                    String v = rs.getString("icon");
                    if (v != null && !v.isEmpty()) icon = "fas " + v; // old schema stored "fa-tag" style
                }
                cat.setIconClass(icon);
                list.add(cat);
            }
        }
        return list;
    }
}
