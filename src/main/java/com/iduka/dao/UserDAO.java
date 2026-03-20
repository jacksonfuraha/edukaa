package com.iduka.dao;
import com.iduka.model.User;
import com.iduka.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.*;

public class UserDAO {

    private static Boolean useNewSchema   = null;
    private static Boolean hasIdNumber    = null;
    private static Boolean hasIdCardUrl   = null;

    private boolean isNewSchema(Connection c) throws SQLException {
        if (useNewSchema != null) return useNewSchema;
        ResultSet rs = c.getMetaData().getColumns(null, null, "users", "password");
        useNewSchema = rs.next();
        return useNewSchema;
    }

    private boolean hasIdNumber(Connection c) throws SQLException {
        if (hasIdNumber != null) return hasIdNumber;
        ResultSet rs = c.getMetaData().getColumns(null, null, "users", "id_number");
        hasIdNumber = rs.next();
        return hasIdNumber;
    }

    private boolean hasIdCardUrl(Connection c) throws SQLException {
        if (hasIdCardUrl != null) return hasIdCardUrl;
        ResultSet rs = c.getMetaData().getColumns(null, null, "users", "id_card_url");
        hasIdCardUrl = rs.next();
        return hasIdCardUrl;
    }

    public boolean emailExists(String email) throws SQLException {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT id FROM users WHERE email=?")) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    public boolean register(User u) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            String hashed  = BCrypt.hashpw(u.getPassword(), BCrypt.gensalt(12));
            String pwCol   = isNewSchema(c) ? "password" : "password_hash";
            String cellCol = isNewSchema(c) ? "cell"     : "cell_area";
            boolean withId = hasIdNumber(c);

            String sql;
            if (withId) {
                sql = "INSERT INTO users(full_name,email,phone," + pwCol + ",role,country,province,district,sector," +
                      cellCol + ",village,id_number,tin_number) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";
            } else {
                sql = "INSERT INTO users(full_name,email,phone," + pwCol + ",role,country,province,district,sector," +
                      cellCol + ",village) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
            }

            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, u.getFullName());
                ps.setString(2, u.getEmail());
                ps.setString(3, u.getPhone());
                ps.setString(4, hashed);
                ps.setString(5, u.getRole());
                ps.setString(6, u.getCountry()  != null ? u.getCountry()  : "Rwanda");
                ps.setString(7, u.getProvince() != null ? u.getProvince() : "");
                ps.setString(8, u.getDistrict() != null ? u.getDistrict() : "");
                ps.setString(9, u.getSector()   != null ? u.getSector()   : "");
                ps.setString(10,u.getCell()     != null ? u.getCell()     : "");
                ps.setString(11,u.getVillage()  != null ? u.getVillage()  : "");
                if (withId) {
                    ps.setString(12, u.getIdNumber()  != null ? u.getIdNumber()  : "");
                    ps.setString(13, u.getTinNumber() != null ? u.getTinNumber() : "");
                }
                return ps.executeUpdate() == 1;
            }
        }
    }

    public void updateIdCard(int userId, String idCardUrl) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            if (!hasIdCardUrl(c)) return; // column doesn't exist yet
            try (PreparedStatement ps = c.prepareStatement("UPDATE users SET id_card_url=? WHERE id=?")) {
                ps.setString(1, idCardUrl);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
        }
    }

    public User login(String email, String password) throws SQLException {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM users WHERE email=?")) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String hashed = null;
                try { hashed = rs.getString("password");      } catch (SQLException ignored) {}
                if (hashed == null)
                try { hashed = rs.getString("password_hash"); } catch (SQLException ignored) {}
                boolean active = true;
                try { active = rs.getBoolean("active");    } catch (SQLException e) {
                try { active = rs.getBoolean("is_active"); } catch (SQLException e2) {} }
                if (hashed != null && active && BCrypt.checkpw(password, hashed))
                    return mapUser(rs);
            }
        }
        return null;
    }

    public User findById(int id) throws SQLException {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM users WHERE id=?")) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapUser(rs) : null;
        }
    }

    public boolean updateProfile(User u) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            String cellCol = isNewSchema(c) ? "cell" : "cell_area";
            String sql = "UPDATE users SET full_name=?,phone=?,country=?,province=?,district=?,sector=?," +
                         cellCol + "=?,village=? WHERE id=?";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1,u.getFullName()); ps.setString(2,u.getPhone());
                ps.setString(3,u.getCountry());  ps.setString(4,u.getProvince());
                ps.setString(5,u.getDistrict()); ps.setString(6,u.getSector());
                ps.setString(7,u.getCell());     ps.setString(8,u.getVillage());
                ps.setInt(9,u.getId());
                return ps.executeUpdate() == 1;
            }
        }
    }

    public boolean changePassword(int userId, String oldPw, String newPw) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            String pwCol = isNewSchema(c) ? "password" : "password_hash";
            try (PreparedStatement ps = c.prepareStatement("SELECT "+pwCol+" FROM users WHERE id=?")) {
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                if (rs.next() && BCrypt.checkpw(oldPw, rs.getString(1))) {
                    try (PreparedStatement up = c.prepareStatement("UPDATE users SET "+pwCol+"=? WHERE id=?")) {
                        up.setString(1, BCrypt.hashpw(newPw, BCrypt.gensalt(12)));
                        up.setInt(2, userId);
                        return up.executeUpdate() == 1;
                    }
                }
            }
        }
        return false;
    }

    public boolean updateAvatar(int userId, String avatarUrl) throws SQLException {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement("UPDATE users SET avatar_url=? WHERE id=?")) {
            ps.setString(1, avatarUrl); ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        try { u.setCountry(rs.getString("country"));   } catch (SQLException ignored) {}
        try { u.setProvince(rs.getString("province")); } catch (SQLException ignored) {}
        try { u.setDistrict(rs.getString("district")); } catch (SQLException ignored) {}
        try { u.setSector(rs.getString("sector"));     } catch (SQLException ignored) {}
        try { u.setCell(rs.getString("cell"));         } catch (SQLException e) {
            try { u.setCell(rs.getString("cell_area")); } catch (SQLException ignored) {} }
        try { u.setVillage(rs.getString("village"));   } catch (SQLException ignored) {}
        try { u.setAvatarUrl(rs.getString("avatar_url")); } catch (SQLException e) {
            try { u.setAvatarUrl(rs.getString("profile_picture")); } catch (SQLException ignored) {} }
        try { u.setActive(rs.getBoolean("active"));    } catch (SQLException e) {
            try { u.setActive(rs.getBoolean("is_active")); } catch (SQLException ignored) { u.setActive(true); } }
        try { u.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignored) {}
        try { u.setIdNumber(rs.getString("id_number"));   } catch (SQLException ignored) {}
        try { u.setTinNumber(rs.getString("tin_number")); } catch (SQLException ignored) {}
        try { u.setIdCardUrl(rs.getString("id_card_url")); } catch (SQLException ignored) {}
        try { u.setVerified(rs.getBoolean("verified")); }  catch (SQLException ignored) {}
        return u;
    }
}
