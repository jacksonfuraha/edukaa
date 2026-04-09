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

/* Negotiation Actions */
.negotiation-actions {
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  padding: 12px;
}

.quick-actions {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.quick-actions::-webkit-scrollbar {
  height: 4px;
}

.quick-actions::-webkit-scrollbar-thumb {
  background: #ddd;
  border-radius: 2px;
}

.quick-btn {
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 20px;
  padding: 8px 12px;
  font-size: 0.8rem;
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 4px;
  color: #495057;
}

.quick-btn:hover {
  background: #6c63ff;
  color: #fff;
  border-color: #6c63ff;
  transform: translateY(-1px);
}

.quick-btn i {
  font-size: 0.7rem;
}

/* Price Modal */
.price-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  z-index: 1000;
  align-items: center;
  justify-content: center;
}

.price-modal.show {
  display: flex;
}

.price-modal-content {
  background: #fff;
  border-radius: 12px;
  padding: 24px;
  max-width: 400px;
  width: 90%;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

.price-modal-content h3 {
  margin: 0 0 20px 0;
  color: #333;
  display: flex;
  align-items: center;
  gap: 8px;
}

.price-input-group {
  margin-bottom: 20px;
}

.price-input-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #555;
}

.price-input-group input {
  width: 100%;
  padding: 12px;
  border: 2px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.price-input-group input:focus {
  outline: none;
  border-color: #6c63ff;
}

.price-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn-cancel, .btn-send-offer {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel {
  background: #f8f9fa;
  color: #6c757d;
}

.btn-cancel:hover {
  background: #e9ecef;
}

.btn-send-offer {
  background: #6c63ff;
  color: #fff;
}

.btn-send-offer:hover {
  background: #5a52e0;
}

/* Enhanced Chat Notice */
.chat-notice {
  background: linear-gradient(135deg, #6c63ff, #5a52e0);
  color: #fff;
  padding: 16px;
  border-radius: 12px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}

.chat-notice i {
  font-size: 1.5rem;
  opacity: 0.9;
}

.chat-notice div {
  flex: 1;
}

.chat-notice strong {
  display: block;
  margin-bottom: 4px;
  font-size: 0.95rem;
}

.chat-notice p {
  margin: 0;
  font-size: 0.8rem;
  opacity: 0.9;
}
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
    <div class="chat-notice">
      <i class="fas fa-handshake"></i> 
      <div>
        <strong>Negotiation Hub</strong>
        <p>Discuss price, delivery & availability. Make deals confidently!</p>
      </div>
    </div>

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

  <div class="negotiation-actions">
  <div class="quick-actions">
    <button class="quick-btn" onclick="insertMessage('Is this product still available?')">
      <i class="fas fa-question-circle"></i> Available?
    </button>
    <button class="quick-btn" onclick="insertMessage('Can you offer a better price?')">
      <i class="fas fa-tag"></i> Better Price?
    </button>
    <button class="quick-btn" onclick="showPriceModal()">
      <i class="fas fa-handshake"></i> Make Offer
    </button>
    <button class="quick-btn" onclick="insertMessage('Can you deliver to [my location]?')">
      <i class="fas fa-truck"></i> Delivery?
    </button>
  </div>
</div>

<form method="post" action="<%=ctx%>/chat/send" class="chat-input-form">
  <input type="hidden" name="receiverId" value="${otherId}">
  <input type="hidden" name="productId"  value="${productId}">
  <div class="chat-input-wrap">
    <input type="text" name="message" id="messageInput" placeholder="Type your message or use quick actions..." required autocomplete="off">
    <button type="submit"><i class="fas fa-paper-plane"></i></button>
  </div>
</form>

<!-- Price Offer Modal -->
<div class="price-modal" id="priceModal">
  <div class="price-modal-content">
    <h3><i class="fas fa-handshake"></i> Make a Price Offer</h3>
    <div class="price-input-group">
      <label>Your Offer (RWF):</label>
      <input type="number" id="priceOffer" placeholder="Enter your offer" min="0">
    </div>
    <div class="price-actions">
      <button class="btn-cancel" onclick="closePriceModal()">Cancel</button>
      <button class="btn-send-offer" onclick="sendPriceOffer()">Send Offer</button>
    </div>
  </div>
</div>
</div>
<script>
// Auto-scroll to bottom
document.getElementById('chatMessages').scrollTop = 999999;

// Negotiation functions
function insertMessage(message) {
  var input = document.getElementById('messageInput');
  if (input) {
    input.value = message;
    input.focus();
  }
}

function showPriceModal() {
  var modal = document.getElementById('priceModal');
  if (modal) {
    modal.classList.add('show');
    document.getElementById('priceOffer').focus();
  }
}

function closePriceModal() {
  var modal = document.getElementById('priceModal');
  if (modal) {
    modal.classList.remove('show');
    document.getElementById('priceOffer').value = '';
  }
}

function sendPriceOffer() {
  var priceInput = document.getElementById('priceOffer');
  var price = priceInput.value.trim();
  
  if (!price || price <= 0) {
    alert('Please enter a valid price offer');
    return;
  }
  
  var messageInput = document.getElementById('messageInput');
  messageInput.value = 'I would like to offer RWF ' + Number(price).toLocaleString() + ' for this product. Is this acceptable?';
  
  closePriceModal();
  
  // Submit the form
  var form = document.querySelector('.chat-input-form');
  if (form) {
    form.submit();
  }
}

// Close modal when clicking outside
document.getElementById('priceModal').addEventListener('click', function(e) {
  if (e.target === this) {
    closePriceModal();
  }
});

// Handle Enter key in price input
document.getElementById('priceOffer').addEventListener('keypress', function(e) {
  if (e.key === 'Enter') {
    sendPriceOffer();
  }
});

// Add some animation to quick buttons
document.querySelectorAll('.quick-btn').forEach(function(btn) {
  btn.addEventListener('click', function() {
    this.style.transform = 'scale(0.95)';
    setTimeout(() => {
      this.style.transform = '';
    }, 100);
  });
});
</script>
</body></html>
