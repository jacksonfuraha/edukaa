package com.iduka.servlet;

import com.iduka.dao.*;
import com.iduka.model.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;

@WebServlet(urlPatterns = {"/videos", "/seller/uploadVideo", "/videos/like", "/videos/comment"})
@MultipartConfig(maxFileSize = 104857600, maxRequestSize = 110100480)
public class VideoServlet extends HttpServlet {

    private final VideoDAO   videoDAO   = new VideoDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private static final String UPLOAD_BASE =
        com.iduka.util.UploadConfig.getUploadBase();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String path = req.getServletPath();

        // GET /videos/comment?videoId=X  — return comments as JSON
        if ("/videos/comment".equals(path)) {
            serveComments(req, res); return;
        }

        if ("/seller/uploadVideo".equals(path)) {
            HttpSession s = req.getSession(false);
            if (s == null) { res.sendRedirect(req.getContextPath()+"/login"); return; }
            int sellerId = (int) s.getAttribute("userId");
            try {
                req.setAttribute("sellerProducts", productDAO.getBySeller(sellerId));
                req.getRequestDispatcher("/jsp/seller/upload_video.jsp").forward(req, res);
            } catch (Exception e) { throw new ServletException(e); }
            return;
        }

        // GET /videos — main video feed
        try {
            List<ProductVideo> videos = videoDAO.getAll();
            req.setAttribute("videos", videos);

            // Pass liked video IDs for current user
            HttpSession session = req.getSession(false);
            Set<Integer> likedIds = new HashSet<>();
            if (session != null && session.getAttribute("userId") != null) {
                int uid = (int) session.getAttribute("userId");
                for (ProductVideo v : videos) {
                    if (videoDAO.isLiked(v.getId(), uid)) likedIds.add(v.getId());
                }
            }
            req.setAttribute("likedVideoIds", likedIds);
            req.getRequestDispatcher("/jsp/common/videos.jsp").forward(req, res);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String path = req.getServletPath();

        // POST /videos/like  — toggle like, return JSON
        if ("/videos/like".equals(path)) {
            res.setContentType("application/json;charset=UTF-8");
            HttpSession session = req.getSession(false);
            int userId = (session != null && session.getAttribute("userId") != null)
                         ? (int) session.getAttribute("userId") : 0;
            try {
                int videoId = Integer.parseInt(req.getParameter("videoId"));
                int newCount = videoDAO.toggleLike(videoId, userId);
                boolean liked = videoDAO.isLiked(videoId, userId);
                res.getWriter().write("{\"likes\":" + newCount + ",\"liked\":" + liked + "}");
            } catch (Exception e) {
                res.getWriter().write("{\"likes\":0,\"liked\":false}");
            }
            return;
        }

        // POST /videos/comment  — add comment, return JSON
        if ("/videos/comment".equals(path)) {
            res.setContentType("application/json;charset=UTF-8");
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                res.getWriter().write("{\"error\":\"login_required\"}"); return;
            }
            int userId = (int) session.getAttribute("userId");
            try {
                int    videoId = Integer.parseInt(req.getParameter("videoId"));
                String text    = req.getParameter("comment");
                if (text == null || text.trim().isEmpty()) {
                    res.getWriter().write("{\"error\":\"empty\"}"); return;
                }
                VideoComment cm = videoDAO.addComment(videoId, userId, text.trim());
                if (cm != null) {
                    String userName = esc(cm.getUserName());
                    String comment  = esc(cm.getComment());
                    String time     = cm.getCreatedAt() != null ? cm.getCreatedAt().toString() : "";
                    String avatar   = cm.getAvatarUrl() != null ? cm.getAvatarUrl() : "";
                    res.getWriter().write(
                        "{\"id\":" + cm.getId() +
                        ",\"userName\":\"" + userName + "\"" +
                        ",\"comment\":\"" + comment + "\"" +
                        ",\"avatarUrl\":\"" + avatar + "\"" +
                        ",\"time\":\"" + time + "\"}");
                } else {
                    res.getWriter().write("{\"error\":\"failed\"}");
                }
            } catch (Exception e) {
                res.getWriter().write("{\"error\":\"" + esc(e.getMessage()) + "\"}");
            }
            return;
        }

        // Old like via ?like=ID (keep for compatibility)
        if (req.getParameter("like") != null) {
            try {
                int videoId = Integer.parseInt(req.getParameter("like"));
                HttpSession session = req.getSession(false);
                int uid = (session != null && session.getAttribute("userId") != null)
                          ? (int) session.getAttribute("userId") : 0;
                videoDAO.toggleLike(videoId, uid);
            } catch (Exception ignored) {}
            res.setStatus(200);
            return;
        }

        // POST to /seller/uploadVideo — upload new video
        if ("/seller/uploadVideo".equals(path)) {
            uploadVideo(req, res); return;
        }
    }

    private void serveComments(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        try {
            int videoId = Integer.parseInt(req.getParameter("videoId"));
            List<VideoComment> list = videoDAO.getComments(videoId);
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < list.size(); i++) {
                VideoComment cm = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(cm.getId())
                  .append(",\"userName\":\"").append(esc(cm.getUserName())).append("\"")
                  .append(",\"comment\":\"").append(esc(cm.getComment())).append("\"")
                  .append(",\"avatarUrl\":\"").append(cm.getAvatarUrl()!=null?esc(cm.getAvatarUrl()):"").append("\"")
                  .append(",\"time\":\"").append(cm.getCreatedAt()!=null?cm.getCreatedAt().toString():"").append("\"")
                  .append("}");
            }
            sb.append("]");
            res.getWriter().write(sb.toString());
        } catch (Exception e) {
            res.getWriter().write("[]");
        }
    }

    private void uploadVideo(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        int sellerId = (int) req.getSession().getAttribute("userId");
        try {
            Part videoPart = req.getPart("video");
            if (videoPart == null || videoPart.getSize() == 0) {
                req.setAttribute("error", "Please select a video file.");
                req.setAttribute("sellerProducts", productDAO.getBySeller(sellerId));
                req.getRequestDispatcher("/jsp/seller/upload_video.jsp").forward(req, res);
                return;
            }
            String origName = videoPart.getSubmittedFileName();
            String ext = (origName != null && origName.contains("."))
                ? origName.substring(origName.lastIndexOf('.')).toLowerCase() : ".mp4";
            if (!ext.matches("\\.(mp4|mov|avi|webm|mkv)")) ext = ".mp4";
            String fileName = UUID.randomUUID() + ext;
            Path dir = Paths.get(UPLOAD_BASE, "videos");
            Files.createDirectories(dir);
            try (InputStream in = videoPart.getInputStream()) {
                Files.copy(in, dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            }
            ProductVideo v = new ProductVideo();
            v.setSellerId(sellerId);
            v.setProductId(Integer.parseInt(req.getParameter("productId")));
            v.setTitle(req.getParameter("title"));
            v.setVideoUrl("videos/" + fileName);
            v.setThumbnailUrl("");
            videoDAO.addVideo(v);
            res.sendRedirect(req.getContextPath() + "/videos?success=Video+uploaded!");
        } catch (Exception e) { throw new ServletException(e); }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n"," ").replace("\r","");
    }

    private static final long serialVersionUID = 1L;
}
