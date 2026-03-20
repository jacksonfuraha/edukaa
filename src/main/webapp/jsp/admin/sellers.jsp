<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Admin — Seller Verification | IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
body { background: #f4f4f8; }
.admin-wrap { max-width: 1100px; margin: 0 auto; padding: 24px 16px; }
.admin-header {
  background: linear-gradient(135deg,#1a1a2e,#16213e);
  color: #fff; padding: 24px 32px; border-radius: 16px;
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 24px;
}
.admin-header h1 { font-size: 1.4rem; font-weight: 800; }
.admin-header p  { font-size: .85rem; color: rgba(255,255,255,.6); margin-top:4px; }
.badge-count {
  background: #e74c3c; color: #fff; font-size: .85rem;
  font-weight: 800; border-radius: 50px; padding: 4px 14px;
}
.seller-card {
  background: #fff; border-radius: 16px;
  box-shadow: 0 2px 16px rgba(0,0,0,.07);
  padding: 24px; margin-bottom: 20px;
  border-left: 5px solid #f39c12;
}
.seller-card.approved { border-left-color: #27ae60; }
.seller-top {
  display: flex; align-items: flex-start;
  justify-content: space-between; flex-wrap: wrap; gap: 12px;
  margin-bottom: 16px;
}
.seller-name { font-size: 1.1rem; font-weight: 800; color: #1a1a2e; }
.seller-email { font-size: .85rem; color: #888; margin-top: 2px; }
.seller-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(200px,1fr));
  gap: 12px; margin-bottom: 20px;
}
.info-box {
  background: #f8f8fc; border-radius: 10px; padding: 12px 14px;
}
.info-label { font-size: .72rem; color: #999; font-weight: 700;
  text-transform: uppercase; letter-spacing: .05em; margin-bottom: 4px; }
.info-val { font-size: .9rem; font-weight: 600; color: #333; }
.id-card-img {
  width: 100%; max-width: 400px; border-radius: 10px;
  border: 2px solid #e0e0e0; margin-bottom: 16px;
  display: block;
}
.action-btns { display: flex; gap: 10px; flex-wrap: wrap; }
.btn-approve {
  background: linear-gradient(135deg,#27ae60,#2ecc71);
  color: #fff; border: none; padding: 10px 24px;
  border-radius: 50px; font-weight: 700; font-size: .9rem;
  cursor: pointer; display: flex; align-items: center; gap: 8px;
}
.btn-approve:hover { opacity: .9; }
.btn-reject {
  background: #fff; color: #e74c3c;
  border: 2px solid #e74c3c; padding: 10px 24px;
  border-radius: 50px; font-weight: 700; font-size: .9rem;
  cursor: pointer; display: flex; align-items: center; gap: 8px;
}
.btn-reject:hover { background: #fee2e2; }
.empty-state {
  text-align: center; padding: 60px 20px; color: #aaa;
}
.empty-state i { font-size: 4rem; display: block; margin-bottom: 16px; color: #27ae60; }
.reg-date { font-size: .78rem; color: #aaa; }
.alert { padding: 12px 16px; border-radius: 10px; margin-bottom: 20px; font-weight: 600; }
.alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
</style>
</head>
<body>
<jsp:include page="../common/header.jsp"/>

<div class="admin-wrap">
  <div class="admin-header">
    <div>
      <h1><i class="fas fa-shield-alt"></i> Seller Verification Panel</h1>
      <p>Review and approve seller identity documents before they can list products</p>
    </div>
    <span class="badge-count">${fn:length(pendingSellers)} pending</span>
  </div>

  <c:if test="${not empty param.success}">
    <div class="alert alert-success">
      <i class="fas fa-check-circle"></i> ${param.success}
    </div>
  </c:if>

  <c:choose>
    <c:when test="${empty pendingSellers}">
      <div class="empty-state">
        <i class="fas fa-check-double"></i>
        <h3 style="color:#27ae60;margin-bottom:8px">All caught up!</h3>
        <p>No sellers are waiting for verification right now.</p>
      </div>
    </c:when>
    <c:otherwise>
      <c:forEach var="seller" items="${pendingSellers}">
      <div class="seller-card">
        <div class="seller-top">
          <div>
            <div class="seller-name">
              <i class="fas fa-user-tie" style="color:#6c63ff"></i>
              ${seller.fullName}
            </div>
            <div class="seller-email">
              <i class="fas fa-envelope"></i> ${seller.email}
              &nbsp;|&nbsp;
              <i class="fas fa-phone"></i> ${seller.phone}
            </div>
            <div class="reg-date">
              <i class="fas fa-calendar"></i> Registered:
              <fmt:formatDate value="${seller.createdAt}" pattern="dd MMM yyyy HH:mm"/>
            </div>
          </div>
          <span style="background:#fff3cd;color:#856404;padding:4px 14px;border-radius:50px;font-size:.78rem;font-weight:700">
            ⏳ PENDING REVIEW
          </span>
        </div>

        <div class="seller-grid">
          <div class="info-box">
            <div class="info-label"><i class="fas fa-id-card"></i> National ID</div>
            <div class="info-val" style="font-family:monospace;letter-spacing:1px">
              ${seller.idNumber}
            </div>
          </div>
          <div class="info-box">
            <div class="info-label"><i class="fas fa-building"></i> TIN Number</div>
            <div class="info-val" style="font-family:monospace;letter-spacing:1px">
              ${seller.tinNumber}
            </div>
          </div>
          <div class="info-box">
            <div class="info-label"><i class="fas fa-map-marker-alt"></i> Location</div>
            <div class="info-val">${seller.district}, ${seller.province}</div>
          </div>
          <div class="info-box">
            <div class="info-label"><i class="fas fa-user"></i> Seller ID</div>
            <div class="info-val">#${seller.id}</div>
          </div>
        </div>

        <%-- ID Card Photo --%>
        <c:if test="${not empty seller.idCardUrl}">
          <div style="margin-bottom:16px">
            <div class="info-label" style="margin-bottom:8px">
              <i class="fas fa-camera"></i> ID CARD PHOTO
            </div>
            <c:choose>
              <c:when test="${fn:startsWith(seller.idCardUrl, 'http')}">
                <img src="${seller.idCardUrl}" class="id-card-img" alt="ID Card">
              </c:when>
              <c:otherwise>
                <img src="<%=ctx%>/uploads/${seller.idCardUrl}" class="id-card-img" alt="ID Card">
              </c:otherwise>
            </c:choose>
          </div>
        </c:if>
        <c:if test="${empty seller.idCardUrl}">
          <div style="background:#fee2e2;color:#991b1b;padding:10px 14px;border-radius:8px;margin-bottom:16px;font-size:.85rem">
            <i class="fas fa-exclamation-triangle"></i> No ID card photo uploaded — consider rejecting this application
          </div>
        </c:if>

        <%-- Action buttons --%>
        <div class="action-btns">
          <form method="post" action="<%=ctx%>/admin/verify"
                onsubmit="return confirm('Approve ${seller.fullName} as a seller? They will be notified by email.')">
            <input type="hidden" name="userId" value="${seller.id}">
            <input type="hidden" name="action" value="approve">
            <button type="submit" class="btn-approve">
              <i class="fas fa-check-circle"></i> Approve Seller
            </button>
          </form>
          <form method="post" action="<%=ctx%>/admin/verify"
                onsubmit="return confirm('Reject ${seller.fullName}? They will be notified and their account deactivated.')">
            <input type="hidden" name="userId" value="${seller.id}">
            <input type="hidden" name="action" value="reject">
            <button type="submit" class="btn-reject">
              <i class="fas fa-times-circle"></i> Reject
            </button>
          </form>
        </div>
      </div>
      </c:forEach>
    </c:otherwise>
  </c:choose>
</div>

<script src="<%=ctx%>/js/main.js"></script>
</body></html>
