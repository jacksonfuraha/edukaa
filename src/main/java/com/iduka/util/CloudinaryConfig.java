package com.iduka.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * Cloudinary integration for permanent video/image storage.
 *
 * Set these in Render environment variables:
 *   CLOUDINARY_CLOUD_NAME = your cloud name
 *   CLOUDINARY_API_KEY    = your api key
 *   CLOUDINARY_API_SECRET = your api secret
 *
 * Free account: 25GB storage — sign up at cloudinary.com
 */
public class CloudinaryConfig {

    private static Cloudinary cloudinary;
    private static boolean    enabled = false;

    static {
        String cloudName = System.getenv("CLOUDINARY_CLOUD_NAME");
        String apiKey    = System.getenv("CLOUDINARY_API_KEY");
        String apiSecret = System.getenv("CLOUDINARY_API_SECRET");

        if (cloudName != null && !cloudName.isEmpty() &&
            apiKey    != null && !apiKey.isEmpty()    &&
            apiSecret != null && !apiSecret.isEmpty()) {
            try {
                Map<String, String> config = new HashMap<>();
                config.put("cloud_name", cloudName);
                config.put("api_key",    apiKey);
                config.put("api_secret", apiSecret);
                config.put("secure",     "true");
                cloudinary = new Cloudinary(config);
                enabled    = true;
                System.out.println("[Cloudinary] Enabled — " + cloudName);
            } catch (Exception e) {
                System.err.println("[Cloudinary] Init failed: " + e.getMessage());
            }
        } else {
            System.out.println("[Cloudinary] Not configured — using local storage");
        }
    }

    public static boolean isEnabled() { return enabled; }

    /** Upload video to Cloudinary, returns secure URL */
    @SuppressWarnings("unchecked")
    public static String uploadVideo(InputStream stream, String fileName) throws Exception {
        Map<String, Object> options = new HashMap<>();
        options.put("resource_type", "video");
        options.put("folder",        "iduka/videos");
        options.put("public_id",     fileName.replaceAll("\\.[^.]+$", ""));
        options.put("overwrite",     Boolean.TRUE);
        Map<?, ?> result = cloudinary.uploader().uploadLarge(stream, options);
        return (String) result.get("secure_url");
    }

    /** Upload image to Cloudinary, returns secure URL */
    @SuppressWarnings("unchecked")
    public static String uploadImage(InputStream stream, String fileName) throws Exception {
        Map<String, Object> options = new HashMap<>();
        options.put("resource_type", "image");
        options.put("folder",        "iduka/images");
        options.put("public_id",     fileName.replaceAll("\\.[^.]+$", ""));
        options.put("overwrite",     Boolean.TRUE);
        Map<?, ?> result = cloudinary.uploader().upload(stream, options);
        return (String) result.get("secure_url");
    }
}
