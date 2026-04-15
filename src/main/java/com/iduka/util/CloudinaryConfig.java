package com.iduka.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

/**
 * Cloudinary integration for permanent video/image storage.
 * 
 * Set these in Render environment variables:
 *   CLOUDINARY_CLOUD_NAME = your cloud name
 *   CLOUDINARY_API_KEY    = your api key  
 *   CLOUDINARY_API_SECRET = your api secret
 *
 * Free account: 25GB storage, 25GB bandwidth/month — plenty for IDUKA.
 * Sign up at: cloudinary.com
 */
public class CloudinaryConfig {

    private static Cloudinary cloudinary;
    private static boolean enabled = false;

    static {
        String cloudName = System.getenv("CLOUDINARY_CLOUD_NAME");
        String apiKey    = System.getenv("CLOUDINARY_API_KEY");
        String apiSecret = System.getenv("CLOUDINARY_API_SECRET");

        if (cloudName != null && !cloudName.isEmpty() &&
            apiKey    != null && !apiKey.isEmpty()    &&
            apiSecret != null && !apiSecret.isEmpty()) {
            try {
                cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", cloudName,
                    "api_key",    apiKey,
                    "api_secret", apiSecret,
                    "secure",     true
                ));
                enabled = true;
                System.out.println("[Cloudinary] ✅ Enabled — " + cloudName);
            } catch (Exception e) {
                System.err.println("[Cloudinary] Init failed: " + e.getMessage());
            }
        } else {
            System.out.println("[Cloudinary] Not configured — using local storage");
        }
    }

    public static boolean isEnabled() { return enabled; }

    /** Upload a video file to Cloudinary, returns the secure URL */
    public static String uploadVideo(InputStream stream, String fileName) throws Exception {
        Map result = cloudinary.uploader().uploadLarge(stream, ObjectUtils.asMap(
            "resource_type", "video",
            "folder",        "iduka/videos",
            "public_id",     fileName.replaceAll("\\.[^.]+$", ""),
            "overwrite",     true
        ));
        return (String) result.get("secure_url");
    }

    /** Upload an image file to Cloudinary, returns the secure URL */
    public static String uploadImage(InputStream stream, String fileName) throws Exception {
        Map result = cloudinary.uploader().upload(stream, ObjectUtils.asMap(
            "resource_type", "image",
            "folder",        "iduka/images",
            "public_id",     fileName.replaceAll("\\.[^.]+$", ""),
            "overwrite",     true
        ));
        return (String) result.get("secure_url");
    }
}
