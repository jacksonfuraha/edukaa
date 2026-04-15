<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Messages - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<jsp:include page="../common/css_chat_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.inbox-unread-dot {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 20px;
  height: 20px;
  background: #6c63ff;
  color: #fff;
  font-size: .65rem;
  font-weight: 800;
  border-radius: 50px;
  padding: 0 5px;
  margin-left: auto;
  flex-shrink: 0;
}
.inbox-last-msg {
  font-size: .8rem;
  color: #888;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 260px;
}
.inbox-item { display: flex; align-items: center; gap: 12px; }
.inbox-info { flex: 1; min-width: 0; }
</style>
</head>
<body>
<jsp:include page="../common/header.jsp"/>
<div class="container mt-4">
  <h2 class="page-title"><i class="fas fa-comments"></i> My Messages</h2>
  <div class="inbox-list">
    <c:choose>
      <c:when test="${not empty inbox}">
        <c:forEach var="conv" items="${inbox}">
        <a href="<%=ctx%>/chat?userId=${conv.otherId}&productId=${conv.productId}" class="inbox-item">
          <div class="inbox-avatar">
            <i class="fas fa-user-circle fa-2x"></i>
          </div>
          <div class="inbox-info">
            <strong>${conv.otherName}</strong>
            <span class="inbox-product">
              <i class="fas fa-box"></i>
              <c:choose>
                <c:when test="${not empty conv.productName}">${conv.productName}</c:when>
                <c:otherwise>Product #${conv.productId}</c:otherwise>
              </c:choose>
            </span>
            <div class="inbox-last-msg">
              <c:out value="${conv.lastMessage}"/>
            </div>
          </div>
          <div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px;flex-shrink:0">
            <div class="inbox-time">
              <fmt:formatDate value="${conv.lastTime}" pattern="dd MMM HH:mm"/>
            </div>
            <c:if test="${conv.unreadCount > 0}">
              <span class="inbox-unread-dot">${conv.unreadCount}</span>
            </c:if>
          </div>
        </a>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <div class="empty-state">
          <i class="fas fa-comment-slash fa-3x"></i>
          <p>No conversations yet.</p>
          <a href="<%=ctx%>/home" class="btn-primary" style="display:inline-block;margin-top:12px">
            Browse Products
          </a>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>
<script src="<%=ctx%>/js/main.js"></script>
</body></html>
