package com.iduka.servlet;

import com.iduka.util.UploadConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.nio.file.*;

/**
 * Serves uploaded files with HTTP Range request support (needed for video streaming).
 */
@WebServlet("/uploads/*")
public class FileServlet extends HttpServlet {

    private String baseDir;

    @Override
    public void init() {
        baseDir = UploadConfig.getUploadBase();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) { res.sendError(404); return; }

        // Security: block path traversal
        if (pathInfo.contains("..") || pathInfo.contains("\\")) { res.sendError(403); return; }

        File file = new File(baseDir + pathInfo);
        if (!file.exists() || !file.isFile()) { res.sendError(404); return; }

        String mime = getServletContext().getMimeType(file.getName());
        if (mime == null) mime = guessMime(pathInfo);
        res.setContentType(mime);

        boolean isVideo = mime.startsWith("video/");
        if (isVideo) {
            res.setHeader("Cache-Control", "no-cache");
            res.setHeader("Accept-Ranges", "bytes");
        } else {
            res.setHeader("Cache-Control", "public, max-age=86400");
        }

        String rangeHeader = req.getHeader("Range");
        if (isVideo && rangeHeader != null) {
            serveRange(req, res, file, rangeHeader);
        } else {
            res.setContentLengthLong(file.length());
            try (InputStream in = new FileInputStream(file);
                 OutputStream out = res.getOutputStream()) {
                byte[] buf = new byte[65536];
                int n;
                while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
            }
        }
    }

    private void serveRange(HttpServletRequest req, HttpServletResponse res,
                             File file, String rangeHeader) throws IOException {
        long fileLen = file.length();
        long start = 0, end = fileLen - 1;
        try {
            String range = rangeHeader.replace("bytes=", "").trim();
            String[] parts = range.split("-");
            if (!parts[0].isEmpty()) start = Long.parseLong(parts[0]);
            if (parts.length > 1 && !parts[1].isEmpty()) end = Long.parseLong(parts[1]);
        } catch (Exception e) { res.sendError(416); return; }

        if (start > end || end >= fileLen) { res.sendError(416); return; }
        long contentLen = end - start + 1;

        res.setStatus(206);
        res.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLen);
        res.setContentLengthLong(contentLen);

        try (RandomAccessFile raf = new RandomAccessFile(file, "r");
             OutputStream out = res.getOutputStream()) {
            raf.seek(start);
            byte[] buf = new byte[65536];
            long remaining = contentLen;
            int n;
            while (remaining > 0 && (n = raf.read(buf, 0, (int) Math.min(buf.length, remaining))) != -1) {
                out.write(buf, 0, n);
                remaining -= n;
            }
        }
    }

    private String guessMime(String path) {
        String p = path.toLowerCase();
        if (p.endsWith(".mp4"))  return "video/mp4";
        if (p.endsWith(".webm")) return "video/webm";
        if (p.endsWith(".mov"))  return "video/quicktime";
        if (p.endsWith(".jpg") || p.endsWith(".jpeg")) return "image/jpeg";
        if (p.endsWith(".png"))  return "image/png";
        if (p.endsWith(".gif"))  return "image/gif";
        if (p.endsWith(".webp")) return "image/webp";
        return "application/octet-stream";
    }
}
