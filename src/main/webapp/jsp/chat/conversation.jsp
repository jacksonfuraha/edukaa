<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Chat - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<jsp:include page="../common/css_chat_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* ── WhatsApp-style tick icons ── */
.msg-status {
  display: inline-flex;
  align-items: center;
  gap: 1px;
  margin-left: 4px;
  font-size: .7rem;
}
/* Single grey tick = sent */
.tick-sent    { color: #aaa; }
/* Double grey tick = delivered */
.tick-delivered { color: #aaa; }
/* Double blue tick = seen */
.tick-seen    { color: #34b7f1; }

.msg-status i { font-size: .68rem; }

/* Ticks only show on sent bubbles (right side) */
.bubble-meta {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 4px;
  margin-top: 3px;
}
.chat-bubble.sent .bubble-meta { justify-content: flex-end; }
.chat-bubble.received .bubble-meta { justify-content: flex-start; }
.chat-bubble.received .msg-status { display: none; }
</style>
</head>
<body>
<jsp:include page="../common/header.jsp"/>
<div class="chat-page-wrap">
  <div class="chat-header-bar">
    <a href="<%=ctx%>/chat/inbox" class="back-btn"><i class="fas fa-arrow-left"></i></a>
    <div class="chat-user-info">
      <i class="fas fa-user-circle chat-avatar-icon"></i>
      <div>
        <strong>Negotiation Chat</strong>
        <span>Discuss price, delivery &amp; availability</span>
      </div>
    </div>
    <a href="<%=ctx%>/product?id=${productId}" class="view-product-btn">
      <i class="fas fa-box"></i> View Product
    </a>
  </div>

  <div class="chat-messages" id="chatMessages">
    <div class="chat-notice"><i class="fas fa-handshake"></i> Negotiate price and delivery here!</div>

    <c:forEach var="msg" items="${messages}">
    <div class="chat-bubble ${msg.senderId == sessionScope.userId ? 'sent' : 'received'}">
      <div class="bubble-name">${msg.senderName}</div>
      <div class="bubble-text"><c:out value="${msg.message}"/></div>
      <div class="bubble-meta">
        <span class="bubble-time"><fmt:formatDate value="${msg.sentAt}" pattern="HH:mm"/></span>
        <%-- WhatsApp ticks — only visible on messages YOU sent --%>
        <c:if test="${msg.senderId == sessionScope.userId}">
          <c:choose>
            <c:when test="${msg.seen}">
              <%-- Double BLUE ticks = SEEN --%>
              <span class="msg-status tick-seen" title="Seen">
                <i class="fas fa-check-double"></i>
              </span>
            </c:when>
            <c:when test="${msg.delivered}">
              <%-- Double GREY ticks = DELIVERED --%>
              <span class="msg-status tick-delivered" title="Delivered">
                <i class="fas fa-check-double"></i>
              </span>
            </c:when>
            <c:otherwise>
              <%-- Single GREY tick = SENT --%>
              <span class="msg-status tick-sent" title="Sent">
                <i class="fas fa-check"></i>
              </span>
            </c:otherwise>
          </c:choose>
        </c:if>
      </div>
    </div>
    </c:forEach>

    <c:if test="${empty messages}">
      <div class="chat-start-hint">
        <i class="fas fa-comment-dots fa-3x"></i>
        <p>Start the conversation!</p>
      </div>
    </c:if>
  </div>

  <form method="post" action="<%=ctx%>/chat/send" class="chat-input-form">
    <input type="hidden" name="receiverId" value="${otherId}">
    <input type="hidden" name="productId"  value="${productId}">
    <div class="chat-input-wrap">
      <input type="text" name="message" placeholder="Type your message..." required autocomplete="off">
      <button type="submit"><i class="fas fa-paper-plane"></i></button>
    </div>
  </form>
</div>
<script>document.getElementById('chatMessages').scrollTop = 999999;</script>
</body></html>
