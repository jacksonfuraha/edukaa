package com.iduka.util;
import java.io.File;
import java.nio.file.*;

public class UploadConfig {

    public static String getUploadBase() {
        // Custom path set in environment
        String envPath = System.getenv("UPLOAD_PATH");
        if (envPath != null && !envPath.isEmpty()) return envPath;

        // On Render or Railway — use /tmp (writable)
        if (isCloud()) return "/tmp/iduka_uploads";

        // Local development
        return System.getProperty("user.home") + File.separator + "iduka_uploads";
    }

    private static boolean isCloud() {
        return System.getenv("RAILWAY_ENVIRONMENT") != null
            || System.getenv("RAILWAY_PROJECT_ID")  != null
            || System.getenv("RENDER")               != null
            || System.getenv("RENDER_SERVICE_ID")    != null
            || System.getenv("DATABASE_URL")         != null; // Render always sets this
    }

    public static void ensureDir(String subDir) {
        try {
            Files.createDirectories(Paths.get(getUploadBase(), subDir));
        } catch (Exception e) {
            System.err.println("Could not create upload dir: " + e.getMessage());
        }
    }
}
