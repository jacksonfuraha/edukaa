<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>My Orders - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.orders-wrap { max-width: 800px; margin: 0 auto; padding: 20px 16px 100px; }
.order-card {
  background: #fff;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 18px;
  box-shadow: 0 2px 16px rgba(0,0,0,.07);
  border-left: 5px solid #e0e0e0;
}
.order-card.CONFIRMED   { border-left-color: #6c63ff; }
.order-card.PENDING     { border-left-color: #f39c12; }
.order-card.SHIPPED     { border-left-color: #3498db; }
.order-card.DELIVERED   { border-left-color: #27ae60; }
.order-card.CANCELLED   { border-left-color: #e74c3c; }

.order-top { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:14px; flex-wrap:wrap; gap:8px; }
.order-id  { font-weight:800; color:#6c63ff; font-size:1.05rem; }
.order-date{ font-size:.78rem; color:#aaa; }

.order-grid { display:grid; grid-template-columns:1fr 1fr; gap:10px; margin-bottom:14px; }
@media(max-width:500px){ .order-grid { grid-template-columns:1fr; } }
.order-field label { color:#999; font-size:.75rem; display:block; margin-bottom:2px; }
.order-field span  { font-weight:600; color:#333; font-size:.9rem; }

/* Status badges */
.status-badge {
  display:inline-flex; align-items:center; gap:5px;
  padding:4px 12px; border-radius:50px; font-size:.75rem; font-weight:700;
}
.badge-PENDING    { background:#fff3cd; color:#856404; }
.badge-CONFIRMED  { background:#e8e3ff; color:#5b21b6; }
.badge-SHIPPED    { background:#dbeafe; color:#1e40af; }
.badge-DELIVERED  { background:#dcfce7; color:#166534; }
.badge-CANCELLED  { background:#fee2e2; color:#991b1b; }

/* Payment request box */
.payment-request-box {
  border-radius: 14px;
  padding: 18px;
  margin-top: 14px;
  border: 2px solid;
}
.payment-request-box.mtn {
  background: linear-gradient(135deg, #fff9e6, #fffbf0);
  border-color: #f39c12;
}
.payment-request-box.airtel {
  background: linear-gradient(135deg, #fff0f0, #fff5f5);
  border-color: #e74c3c;
}
.payment-request-box.paid {
  background: linear-gradient(135deg, #f0fff4, #e8f5e9);
  border-color: #27ae60;
}
.payment-request-box.bank {
  background: linear-gradient(135deg, #e8f4ff, #f0f8ff);
  border-color: #3498db;
}
.pay-header {
  display: flex; align-items: center; gap: 10px; margin-bottom: 12px;
}
.pay-logo {
  width: 44px; height: 44px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 1.3rem; font-weight: 900; color: #fff; flex-shrink: 0;
}
.pay-logo.mtn    { background: #f39c12; }
.pay-logo.airtel { background: #e74c3c; }
.pay-logo.bank   { background: #3498db; }
.pay-logo.paid   { background: #27ae60; }

.pay-title { font-weight: 700; font-size: 1rem; }
.pay-sub   { font-size: .8rem; color: #666; margin-top: 2px; }

.pay-amount {
  font-size: 1.6rem; font-weight: 900;
  margin: 10px 0;
}
.pay-amount.mtn    { color: #f39c12; }
.pay-amount.airtel { color: #e74c3c; }
.pay-amount.bank   { color: #3498db; }
.pay-amount.paid   { color: #27ae60; }

.pay-instructions {
  background: rgba(0,0,0,.04);
  border-radius: 10px;
  padding: 12px 14px;
  font-size: .85rem;
  color: #444;
  line-height: 1.7;
}
.pay-instructions strong { display: block; margin-bottom: 4px; color: #222; }
.pay-ref {
  display: inline-block;
  background: rgba(0,0,0,.07);
  border-radius: 8px;
  padding: 6px 12px;
  font-family: monospace;
  font-size: .9rem;
  font-weight: 700;
  margin-top: 8px;
  letter-spacing: 1px;
}
.pay-pending-pulse {
  display: inline-flex; align-items: center; gap: 6px;
  font-size: .82rem; color: #f39c12; font-weight: 600; margin-top: 8px;
}
.pulse-dot {
  width: 8px; height: 8px; border-radius: 50%; background: #f39c12;
  animation: pulse 1.4s ease-in-out infinite;
}
@keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.4;transform:scale(1.4)} }
</style>
</head>
<body>
<jsp:include page="../common/header.jsp"/>

<div class="orders-wrap">
  <h2 class="page-title"><i class="fas fa-box"></i> My Orders</h2>

  <c:if test="${not empty param.success}">
    <div class="alert alert-success" style="margin-bottom:16px">
      <i class="fas fa-check-circle"></i> ${param.success}
    </div>
  </c:if>

  <c:choose>
    <c:when test="${empty orders}">
      <div class="empty-state">
        <i class="fas fa-box-open fa-3x"></i>
        <p>No orders yet.</p>
        <a href="<%=ctx%>/home" class="btn-primary" style="display:inline-block;margin-top:12px">Shop Now</a>
      </div>
    </c:when>
    <c:otherwise>
      <c:forEach var="o" items="${orders}">
      <div class="order-card ${o.status}">

        <%-- Order header --%>
        <div class="order-top">
          <div>
            <div class="order-id"><i class="fas fa-hashtag"></i> Order ${o.id}</div>
            <span class="status-badge badge-${o.status}" style="margin-top:4px">
              <c:choose>
                <c:when test="${o.status == 'PENDING'}">⏳</c:when>
                <c:when test="${o.status == 'CONFIRMED'}">✅</c:when>
                <c:when test="${o.status == 'SHIPPED'}">🚚</c:when>
                <c:when test="${o.status == 'DELIVERED'}">📦</c:when>
                <c:when test="${o.status == 'CANCELLED'}">❌</c:when>
              </c:choose>
              ${o.status}
            </span>
          </div>
          <div class="order-date">
            <fmt:formatDate value="${o.createdAt}" pattern="dd MMM yyyy HH:mm"/>
          </div>
        </div>

        <%-- Order details --%>
        <div class="order-grid">
          <div class="order-field"><label>Product</label><span>${o.productName}</span></div>
          <div class="order-field"><label>Seller</label><span>${o.sellerName}</span></div>
          <div class="order-field"><label>Quantity</label><span>${o.quantity} item(s)</span></div>
          <div class="order-field"><label>Total Amount</label>
            <span style="color:#6c63ff;font-size:1.05rem;font-weight:800">
              RWF <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>
            </span>
          </div>
          <div class="order-field"><label>Payment Method</label><span>${o.paymentMethod}</span></div>
          <div class="order-field"><label>Delivery To</label><span>${o.deliveryAddress}</span></div>
        </div>

        <%-- ══════ PAYMENT REQUEST SECTION ══════ --%>
        <c:if test="${o.status == 'CONFIRMED' or o.status == 'SHIPPED' or o.status == 'DELIVERED'}">

          <%-- Determine payment method type --%>
          <c:set var="pmLower"  value="${o.paymentMethod}"/>
          <c:set var="isMTN"    value="${pmLower != null and (pmLower == 'MTN MoMo' or pmLower == 'MTN' or pmLower == 'Mobile Money' or pmLower == 'MTN Mobile Money')}"/>
          <c:set var="isAirtel" value="${pmLower != null and (pmLower == 'Airtel Money' or pmLower == 'Airtel' or pmLower == 'AIRTEL' or pmLower == 'AIRTEL MoMo')}"/>
          <c:set var="isPaid"   value="${o.paymentStatus == 'PAID'}"/>

          <c:choose>
            <%-- PAID --%>
            <c:when test="${isPaid}">
              <div class="payment-request-box paid">
                <div class="pay-header">
                  <div class="pay-logo paid"><i class="fas fa-check"></i></div>
                  <div>
                    <div class="pay-title">Payment Confirmed ✅</div>
                    <div class="pay-sub">Thank you! Your payment has been received.</div>
                  </div>
                </div>
                <c:if test="${not empty o.paymentRef}">
                  <div style="font-size:.82rem;color:#555">Reference number:</div>
                  <div class="pay-ref">${o.paymentRef}</div>
                </c:if>
              </div>
            </c:when>

            <%-- MTN MoMo payment request --%>
            <c:when test="${isMTN or (not isAirtel)}">
              <div class="payment-request-box mtn">
                <div class="pay-header">
                  <div class="pay-logo mtn">M</div>
                  <div>
                    <div class="pay-title" style="color:#f39c12">MTN Mobile Money Request</div>
                    <div class="pay-sub">A payment request has been sent to your phone</div>
                  </div>
                </div>
                <div class="pay-amount mtn">
                  RWF <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>
                </div>
                <div class="pay-instructions">
                  <strong>📱 How to complete your payment:</strong>
                  1. Check your phone for a USSD prompt from MTN MoMo<br>
                  2. If no prompt received, dial <strong>*182#</strong> on your MTN number<br>
                  3. Select <strong>"My Approvals"</strong> or <strong>"Pay"</strong><br>
                  4. Enter your <strong>Mobile Money PIN</strong> to confirm<br>
                  5. You will receive an SMS confirmation
                </div>
                <c:if test="${not empty o.paymentRef}">
                  <div style="margin-top:10px;font-size:.8rem;color:#777">Transaction reference:</div>
                  <div class="pay-ref">${o.paymentRef}</div>
                </c:if>
                <div class="pay-pending-pulse">
                  <span class="pulse-dot"></span>
                  Waiting for your payment confirmation...
                </div>
              </div>
            </c:when>

            <%-- Airtel Money payment request --%>
            <c:when test="${isAirtel}">
              <div class="payment-request-box airtel">
                <div class="pay-header">
                  <div class="pay-logo airtel">A</div>
                  <div>
                    <div class="pay-title" style="color:#e74c3c">Airtel Money Request</div>
                    <div class="pay-sub">A payment request has been sent to your phone</div>
                  </div>
                </div>
                <div class="pay-amount airtel">
                  RWF <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>
                </div>
                <div class="pay-instructions">
                  <strong>📱 How to complete your payment:</strong>
                  1. Check your phone for a prompt from Airtel Money<br>
                  2. If no prompt, dial <strong>*185#</strong> on your Airtel number<br>
                  3. Select <strong>"Pay"</strong> → <strong>"Merchant"</strong><br>
                  4. Enter your <strong>Airtel Money PIN</strong> to confirm<br>
                  5. You will receive an SMS confirmation
                </div>
                <c:if test="${not empty o.paymentRef}">
                  <div style="margin-top:10px;font-size:.8rem;color:#777">Transaction reference:</div>
                  <div class="pay-ref">${o.paymentRef}</div>
                </c:if>
                <div class="pay-pending-pulse" style="color:#e74c3c">
                  <span class="pulse-dot" style="background:#e74c3c"></span>
                  Waiting for your payment confirmation...
                </div>
              </div>
            </c:when>

            <%-- Bank transfer --%>
            <c:otherwise>
              <div class="payment-request-box bank">
                <div class="pay-header">
                  <div class="pay-logo bank"><i class="fas fa-university"></i></div>
                  <div>
                    <div class="pay-title" style="color:#3498db">Bank Transfer Required</div>
                    <div class="pay-sub">Please transfer the amount to complete your order</div>
                  </div>
                </div>
                <div class="pay-amount bank">
                  RWF <fmt:formatNumber value="${o.totalPrice}" pattern="#,###"/>
                </div>
                <div class="pay-instructions">
                  <strong>🏦 Bank Transfer Instructions:</strong>
                  Bank: Bank of Kigali<br>
                  Account Name: IDUKA Online Store<br>
                  Account Number: <strong>00040-00123456-78</strong><br>
                  Reference: <strong>ORDER-${o.id}</strong><br><br>
                  After payment, send your bank receipt to the seller via Chat.
                </div>
                <c:if test="${not empty o.paymentRef}">
                  <div class="pay-ref">${o.paymentRef}</div>
                </c:if>
              </div>
            </c:otherwise>
          </c:choose>

        </c:if>
        <%-- Pending orders — show payment method the buyer chose --%>
        <c:if test="${o.status == 'PENDING'}">
          <div style="margin-top:12px;padding:12px 14px;background:#fafafa;border-radius:10px;font-size:.85rem;color:#666;border:1px dashed #ddd">
            <i class="fas fa-clock" style="color:#f39c12"></i>
            <strong>Waiting for seller to confirm your order.</strong>
            Once confirmed, a payment request will be sent to your phone via ${o.paymentMethod}.
          </div>
        </c:if>

      </div>
      </c:forEach>
    </c:otherwise>
  </c:choose>
</div>

<script src="<%=ctx%>/js/main.js"></script>
</body></html>
