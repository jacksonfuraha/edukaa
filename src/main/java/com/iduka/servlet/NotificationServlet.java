package com.iduka.servlet;

import com.iduka.dao.ChatDAO;
import com.iduka.dao.NotificationDAO;
import com.iduka.model.Notification;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.*;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO dao     = new NotificationDAO();
    private final ChatDAO         chatDAO = new ChatDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control", "no-cache, no-store");
        PrintWriter out = res.getWriter();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            out.write("{\"count\":0,\"chatCount\":0,\"items\":[]}");
            return;
        }
        int userId = (int) session.getAttribute("userId");

        try {
            String action = req.getParameter("action");
            if ("markRead".equals(action)) {
                dao.markAllRead(userId);
                out.write("{\"ok\":true}");
                return;
            }

            List<Notification> list = dao.getUnread(userId);
            int chatCount = 0;
            try { chatCount = chatDAO.countUnread(userId); } catch(Exception ignored){}

            StringBuilder sb = new StringBuilder();
            sb.append("{\"count\":").append(list.size())
              .append(",\"chatCount\":").append(chatCount)
              .append(",\"items\":[");

            for (int i = 0; i < list.size(); i++) {
                Notification n = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{")
                  .append("\"id\":").append(n.getId()).append(",")
                  .append("\"type\":\"").append(esc(n.getType())).append("\",")
                  .append("\"message\":\"").append(esc(n.getMessage())).append("\",")
                  .append("\"link\":\"").append(esc(n.getLink())).append("\",")
                  .append("\"time\":\"").append(n.getCreatedAt()!=null?n.getCreatedAt().toString():"").append("\"")
                  .append("}");
            }
            sb.append("]}");
            out.write(sb.toString());

        } catch (Exception e) {
            System.err.println("NotificationServlet error: " + e.getMessage());
            out.write("{\"count\":0,\"chatCount\":0,\"items\":[]}");
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"")
                .replace("\n"," ").replace("\r","").replace("\t"," ");
    }
}
