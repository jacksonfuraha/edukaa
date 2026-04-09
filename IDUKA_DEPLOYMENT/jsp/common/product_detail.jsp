<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>${product.name} - IDUKA</title>
<jsp:include page="css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.payment-section{background:#f8f9ff;border:1px solid #e0e0ff;border-radius:12px;padding:20px;margin:16px 0}
.payment-section h4{margin:0 0 14px;color:#6c63ff;font-size:1rem}
.pay-options{display:flex;flex-direction:column;gap:10px}
.pay-option{display:flex;align-items:center;gap:10px;padding:12px 16px;background:#fff;border:2px solid #e0e0e0;border-radius:10px;cursor:pointer;transition:all .2s;position:relative}
.pay-option:has(input:checked){border-color:#6c63ff;background:#f0eeff}
.pay-option input[type=radio]{accent-color:#6c63ff}
.pay-option .pay-icon{font-size:1.4rem;width:32px;text-align:center}
.pay-option .pay-label strong{display:block;font-size:.95rem}
.pay-option .pay-label small{color:#888;font-size:.8rem}
.pay-option .recommended{position:absolute;top:4px;right:4px;background:#27ae60;color:#fff;padding:2px 6px;border-radius:12px;font-size:.65rem;font-weight:600}
.momo-input{margin-top:10px;display:none}
.momo-input input{width:100%;padding:10px 14px;border:1px solid #ddd;border-radius:8px;font-size:.95rem}
.order-summary{background:#fff;border:1px solid #e0e0e0;border-radius:10px;padding:16px;margin:12px 0}
.order-summary .sum-row{display:flex;justify-content:space-between;padding:6px 0;font-size:.9rem;color:#555}
.order-summary .sum-total{display:flex;justify-content:space-between;padding:10px 0 0;border-top:2px solid #6c63ff;font-weight:700;color:#6c63ff;font-size:1.1rem}
.payment-security{background:#e8f5e8;border:1px solid #27ae60;border-radius:8px;padding:12px;margin-top:12px;font-size:.85rem;color:#27ae60;display:flex;align-items:center;gap:8px}
.payment-security i{font-size:1rem}
.payment-tips{background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-top:12px;font-size:.85rem;color:#856404}
.payment-tips ul{margin:6px 0;padding-left:16px}
.payment-tips li{margin-bottom:4px}
</style>
</head>
<body><jsp:include page="header.jsp"/>
<div class="container mt-4">
<c:choose>
<c:when test="${not empty product}">
  <c:if test="${not empty param.error}">
    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${param.error}</div>
  </c:if>
  <div class="product-detail-wrap">
    <div class="product-detail-img">
      <c:choose>
        <c:when test="${empty product.imageUrl}">
          <img src="<%=ctx%>/images/no-image.svg" alt="${product.name}" style="width:100%;height:420px;object-fit:cover;border-radius:12px">
        </c:when>
        <c:otherwise>
          <img src="<%=ctx%>/uploads/${product.imageUrl}" alt="${product.name}"
               style="width:100%;height:420px;object-fit:cover;border-radius:12px;background:#f5f7fa"
               onerror="this.onerror=null;this.src='<%=ctx%>/images/no-image.svg'">
        </c:otherwise>
      </c:choose>
    </div>
    <div class="product-detail-info">
      <span class="badge-category"><i class="fas fa-tag"></i> Product</span>
      <h1>${product.name}</h1>
      <p class="detail-seller"><i class="fas fa-store"></i> Sold by: <strong>${product.sellerName}</strong></p>
      <div class="detail-price">RWF ${product.price}</div>
      <p class="detail-stock"><i class="fas fa-boxes"></i> ${product.stock} items in stock</p>
      <p class="detail-desc">${product.description}</p>

      <c:choose>
        <c:when test="${sessionScope.userRole == 'BUYER'}">
          <form method="post" action="<%=ctx%>/buyer/order" id="orderForm">
            <input type="hidden" name="productId" value="${product.id}">

            <%-- Quantity --%>
            <div class="qty-wrap" style="margin-bottom:16px">
              <label style="font-weight:600;display:block;margin-bottom:6px">Quantity</label>
              <input type="number" name="quantity" id="qtyInput" value="1" min="1" max="${product.stock}"
                     class="qty-input" oninput="updateTotal()" style="width:120px">
            </div>

            <%-- Order Summary --%>
            <div class="order-summary">
              <div class="sum-row"><span>Unit Price</span><span>RWF ${product.price}</span></div>
              <div class="sum-row"><span>Quantity</span><span id="sumQty">1</span></div>
              <div class="sum-total"><span>Total</span><span id="sumTotal">RWF ${product.price}</span></div>
            </div>

            <%-- Payment Method --%>
            <div class="payment-section">
              <h4><i class="fas fa-credit-card"></i> Choose Payment Method</h4>
              <div class="pay-options">
                <label class="pay-option">
                  <input type="radio" name="paymentMethod" value="MTN MoMo" required onchange="showMomo('mtn')" checked>
                  <span class="pay-icon">??</span>
                  <span class="pay-label"><strong>MTN Mobile Money</strong><small>Instant & secure payment</small></span>
                  <span class="recommended">Popular</span>
                </label>
                <div class="momo-input" id="mtn-input" style="display:block;">
                  <input type="text" name="mtnNumber" placeholder="MTN number e.g. 0780000000" pattern="[0-9]{10}">
                </div>

                <label class="pay-option">
                  <input type="radio" name="paymentMethod" value="Airtel Money" onchange="showMomo('airtel')">
                  <span class="pay-icon">??</span>
                  <span class="pay-label"><strong>Airtel Money</strong><small>Quick mobile payment</small></span>
                </label>
                <div class="momo-input" id="airtel-input">
                  <input type="text" name="airtelNumber" placeholder="Airtel number e.g. 0720000000" pattern="[0-9]{10}">
                </div>

                <label class="pay-option">
                  <input type="radio" name="paymentMethod" value="Bank Transfer" onchange="showMomo('bank')">
                  <span class="pay-icon">??</span>
                  <span class="pay-label"><strong>Bank Transfer</strong><small>Transfer via Bank of Kigali / Equity</small></span>
                </label>

                <label class="pay-option">
                  <input type="radio" name="paymentMethod" value="Cash on Delivery" onchange="showMomo('cash')">
                  <span class="pay-icon">??</span>
                  <span class="pay-label"><strong>Cash on Delivery</strong><small>Pay when item arrives</small></span>
                </label>
              </div>
              
              <div class="payment-security">
                <i class="fas fa-shield-alt"></i>
                <span><strong>Secure Payment:</strong> Your transactions are protected with encryption and fraud monitoring</span>
              </div>
              
              <div class="payment-tips">
                <strong><i class="fas fa-lightbulb"></i> Mobile Money Tips:</strong>
                <ul>
                  <li>Ensure your phone has sufficient balance</li>
                  <li>You'll receive a USSD prompt to confirm payment</li>
                  <li>Keep your PIN secure and never share it</li>
                  <li>Payment confirmation will be sent via SMS</li>
                </ul>
              </div>
            </div>

            <button type="submit" class="btn-order-full">
              <i class="fas fa-shopping-cart"></i> Place Order
            </button>
          <a href="<%=ctx%>/chat?userId=${product.sellerId}&productId=${product.id}" class="btn-chat-full" style="margin-top:10px">
            <i class="fas fa-comments"></i> Negotiate Price with Seller
          </a>
        </c:when>
        <c:otherwise>
          <div class="login-prompt">
            <p><i class="fas fa-lock"></i> Login to order or chat with seller</p>
            <a href="<%=ctx%>/login" class="btn-primary-full">Login to Buy</a>
            <a href="<%=ctx%>/register" class="btn-outline-full" style="margin-top:10px">Create Account</a>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</c:when>
<c:otherwise>
  <div class="empty-state"><i class="fas fa-box-open fa-3x"></i><p>Product not found.</p></div>
</c:otherwise>
</c:choose>
</div>
<script>
var unitPrice = parseFloat('${product.price}') || 0;
function updateTotal(){
  var qty = parseInt(document.getElementById('qtyInput').value)||1;
  document.getElementById('sumQty').textContent = qty;
  document.getElementById('sumTotal').textContent = 'RWF ' + (unitPrice*qty).toLocaleString('en-US',{minimumFractionDigits:2,maximumFractionDigits:2});
}
function showMomo(type){
  document.querySelectorAll('.momo-input').forEach(d=>d.style.display='none');
  if(type==='mtn'||type==='airtel') document.getElementById(type+'-input').style.display='block';
}
</script>
<script src="<%=ctx%>/js/main.js"></script>
</body></html>
