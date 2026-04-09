package com.iduka.util;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * PostgreSQL connection — reads DATABASE_URL from Render environment.
 * Render provides DATABASE_URL automatically when you add a PostgreSQL database.
 *
 * Format: postgres://user:password@host:port/dbname
 */
public class DBConnection {

    static {
        try { Class.forName("org.postgresql.Driver"); }
        catch (ClassNotFoundException e) { throw new RuntimeException("PostgreSQL Driver not found", e); }
    }

    public static Connection getConnection() throws SQLException {
        // Render sets DATABASE_URL automatically
        String dbUrl = System.getenv("DATABASE_URL");

        if (dbUrl != null && !dbUrl.trim().isEmpty()) {
            // Convert postgres:// URL to JDBC format
            String jdbcUrl = convertToJdbc(dbUrl.trim());
            System.out.println("[DB] Connecting via DATABASE_URL");
            return DriverManager.getConnection(jdbcUrl);
        }

        // Fallback: individual vars (for local dev)
        String host = getEnv("DB_HOST",     "localhost");
        String port = getEnv("DB_PORT",     "5432");
        String db   = getEnv("DB_NAME",     "iduka");
        String user = getEnv("DB_USER",     "postgres");
        String pass = getEnv("DB_PASSWORD", "");

        String url = "jdbc:postgresql://" + host + ":" + port + "/" + db
                   + "?sslmode=prefer&connectTimeout=30";

        System.out.println("[DB] Connecting to: " + host + ":" + port + "/" + db);
        return DriverManager.getConnection(url, user, pass);
    }

    /**
     * Convert Render's postgres:// URL to JDBC URL
     * postgres://user:pass@host:port/db  →  jdbc:postgresql://host:port/db?user=user&password=pass&sslmode=require
     */
    private static String convertToJdbc(String url) {
        try {
            // Handle both postgres:// and postgresql://
            String u = url.replace("postgres://", "").replace("postgresql://", "");
            String userInfo = u.substring(0, u.indexOf('@'));
            String hostPath = u.substring(u.indexOf('@') + 1);
            String user     = userInfo.substring(0, userInfo.indexOf(':'));
            String pass     = userInfo.substring(userInfo.indexOf(':') + 1);
            String host     = hostPath.substring(0, hostPath.indexOf('/'));
            String dbName   = hostPath.substring(hostPath.indexOf('/') + 1);
            // Remove any query params from dbName
            if (dbName.contains("?")) dbName = dbName.substring(0, dbName.indexOf('?'));
            return "jdbc:postgresql://" + host + "/" + dbName
                 + "?user=" + user
                 + "&password=" + pass
                 + "&sslmode=require";
        } catch (Exception e) {
            // If parsing fails, try using the URL directly
            return url.replace("postgres://", "jdbc:postgresql://")
                      .replace("postgresql://", "jdbc:postgresql://");
        }
    }

    private static String getEnv(String key, String def) {
        String v = System.getenv(key);
        return (v != null && !v.trim().isEmpty()) ? v.trim() : def;
    }
}
