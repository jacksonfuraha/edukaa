package com.iduka.servlet;
import com.iduka.dao.ChatDAO;
import com.iduka.model.ChatMessage;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import java.io.IOException;

@WebServlet(urlPatterns={"/chat", "/chat/send", "/chat/inbox"})
public class ChatServlet extends HttpServlet {
    private final ChatDAO chatDAO = new ChatDAO();

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        int userId = (int) req.getSession().getAttribute("userId");
        String path = req.getServletPath();
        try {
            if ("/chat/inbox".equals(path)) {
                req.setAttribute("inbox", chatDAO.getInbox(userId));
                req.getRequestDispatcher("/jsp/chat/inbox.jsp").forward(req, res);
            } else {
                int otherId   = Integer.parseInt(req.getParameter("userId"));
                int productId = Integer.parseInt(req.getParameter("productId"));
                chatDAO.markSeen(userId, otherId, productId);
                req.setAttribute("messages",  chatDAO.getConversation(userId, otherId, productId));
                req.setAttribute("otherId",   otherId);
                req.setAttribute("productId", productId);
                req.getRequestDispatcher("/jsp/chat/conversation.jsp").forward(req, res);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        int senderId = (int) req.getSession().getAttribute("userId");
        try {
            ChatMessage m = new ChatMessage();
            m.setSenderId(senderId);
            m.setReceiverId(Integer.parseInt(req.getParameter("receiverId")));
            m.setProductId(Integer.parseInt(req.getParameter("productId")));
            m.setMessage(req.getParameter("message"));
            chatDAO.sendMessage(m);
            res.sendRedirect(req.getContextPath() + "/chat?userId=" + m.getReceiverId() + "&productId=" + m.getProductId());
        } catch (Exception e) { throw new ServletException(e); }
    }
}
