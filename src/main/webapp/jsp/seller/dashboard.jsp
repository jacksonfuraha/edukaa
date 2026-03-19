<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Seller Dashboard - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<jsp:include page="../common/css_dashboard_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body><jsp:include page="../common/header.jsp"/>
<div class="dashboard-wrap">
  <aside class="sidebar">
    <div class="sidebar-user">
      <div class="sidebar-avatar-wrap">
        <c:choose>
          <c:when test="${not empty sessionScope.user.avatarUrl}">
            <img src="<%=ctx%>/uploads/${sessionScope.user.avatarUrl}"
                 class="sidebar-avatar-img" alt="Profile"
                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
            <div class="sidebar-avatar-initial" style="display:none">
              ${fn:substring(sessionScope.userName,0,1)}
            </div>
          </c:when>
          <c:otherwise>
            <div class="sidebar-avatar-initial">
              ${fn:substring(sessionScope.userName,0,1)}
            </div>
          </c:otherwise>
        </c:choose>
      </div>
      <span>${sessionScope.userName}</span>
      <small>Seller</small>
    </div>
    <nav class="sidebar-nav">
      <a href="#" class="sidebar-link active" onclick="showTab('products',this);return false;"><i class="fas fa-box"></i> My Products</a>
      <a href="#" class="sidebar-link" onclick="showTab('orders',this);return false;"><i class="fas fa-shopping-bag"></i> Orders</a>
      <a href="#" class="sidebar-link" onclick="showTab('videos',this);return false;"><i class="fas fa-play-circle"></i> My Videos</a>
      <a href="<%=ctx%>/seller/addProduct" class="sidebar-link"><i class="fas fa-plus-circle"></i> Add Product</a>
      <a href="<%=ctx%>/seller/uploadVideo" class="sidebar-link"><i class="fas fa-video"></i> Upload Video</a>
      <a href="<%=ctx%>/chat/inbox" class="sidebar-link"><i class="fas fa-comments"></i> Messages</a>
      <a href="<%=ctx%>/profile" class="sidebar-link"><i class="fas fa-cog"></i> Settings</a>
      <a href="<%=ctx%>/logout" class="sidebar-link" style="color:#e74c3c"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
  </aside>
  <main class="dashboard-main">
    <c:if test="${not empty param.success}">
      <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${param.success}</div>
    </c:if>
    <div id="tab-products" class="dash-tab active">
      <%-- Flash messages --%>
      <c:if test="${not empty param.msg}">
        <div style="background:${param.msg=='deleted'?'#fff0f0':'#f0fff4'};border-left:4px solid ${param.msg=='deleted'?'#e74c3c':'#27ae60'};padding:12px 18px;border-radius:8px;margin-bottom:16px;font-size:.88rem;color:${param.msg=='deleted'?'#c0392b':'#1a7f4b'}">
          <i class="fas ${param.msg=='deleted'?'fa-trash':'fa-check-circle'}"></i>
          ${param.msg=='deleted' ? 'Product deleted successfully.' : 'Product updated successfully.'}
        </div>
      </c:if>
      <div class="dash-tab-header">
        <h2><i class="fas fa-box"></i> My Products</h2>
        <a href="<%=ctx%>/seller/addProduct" class="btn-primary"><i class="fas fa-plus"></i> Add Product</a>
      </div>
      <div class="table-responsive">
      <table class="data-table">
        <thead><tr><th>Image</th><th>Name</th><th>Price</th><th>Stock</th><th>Status</th><th>Action</th></tr></thead>
        <tbody>
        <c:forEach var="p" items="${products}">
        <tr>
          <td>
            <c:choose>
              <c:when test="${empty p.imageUrl}">
                <img src="<%=ctx%>/images/no-image.svg" style="width:55px;height:55px;object-fit:cover;border-radius:8px">
              </c:when>
              <c:otherwise>
                <img src="<%=ctx%>/uploads/${p.imageUrl}" style="width:55px;height:55px;object-fit:cover;border-radius:8px"
                     onerror="this.onerror=null;this.src='<%=ctx%>/images/no-image.svg'">
              </c:otherwise>
            </c:choose>
          </td>
          <td>${p.name}</td><td>RWF ${p.price}</td>
          <td><span class="${p.stock < 5 ? 'badge-danger':'badge-success'}">${p.stock}</span></td>
          <td><span class="${p.active?'badge-active':'badge-inactive'}">${p.active?'Active':'Inactive'}</span></td>
          <td style="white-space:nowrap">
            <a href="<%=ctx%>/product?id=${p.id}" class="btn-sm btn-view" title="View"><i class="fas fa-eye"></i></a>
            <a href="<%=ctx%>/seller/editProduct?id=${p.id}" class="btn-sm" style="background:#ede9fe;color:#6c63ff;border-radius:6px;padding:5px 10px;font-size:.78rem;margin:0 3px" title="Edit"><i class="fas fa-edit"></i> Edit</a>
            <a href="<%=ctx%>/seller/editProduct?action=delete&id=${p.id}" class="btn-sm" style="background:#fff0f0;color:#e74c3c;border-radius:6px;padding:5px 10px;font-size:.78rem"
               onclick="return confirm('Delete this product?')" title="Delete"><i class="fas fa-trash"></i></a>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty products}"><tr><td colspan="6" class="text-center">No products. <a href="<%=ctx%>/seller/addProduct">Add one!</a></td></tr></c:if>
        </tbody>
      </table>
      </div>
    </div>
    <div id="tab-orders" class="dash-tab">
      <div class="dash-tab-header"><h2><i class="fas fa-shopping-bag"></i> Orders Received</h2></div>
      <div class="table-responsive">
      <table class="data-table">
        <thead><tr><th>#</th><th>Product</th><th>Buyer & Phone</th><th>Qty</th><th>Total</th><th>Payment</th><th>Status</th><th>Action</th></tr></thead>
        <tbody>
        <c:forEach var="o" items="${orders}">
        <tr>
          <td>#${o.id}</td>
          <td>${o.productName}</td>
          <td>
            ${o.buyerName}<br>
            <small style="color:#6c63ff;font-size:.75rem"><i class="fas fa-phone"></i> ${o.buyerPhone}</small><br>
            <small style="color:#aaa;font-size:.72rem">${o.paymentMethod}</small>
          </td>
          <td>${o.quantity}</td>
          <td style="font-weight:700;color:#6c63ff">RWF ${o.totalPrice}</td>
          <td>
            <c:choose>
              <c:when test="${o.paymentStatus == 'PAID'}">
                <span style="background:#d4edda;color:#155724;padding:3px 10px;border-radius:50px;font-size:.75rem;font-weight:700">✅ PAID</span>
              </c:when>
              <c:when test="${o.paymentStatus == 'PAYMENT_SENT'}">
                <span style="background:#fff3cd;color:#856404;padding:3px 10px;border-radius:50px;font-size:.75rem;font-weight:700">💳 REQUEST SENT</span>
              </c:when>
              <c:otherwise>
                <span style="background:#f8d7da;color:#721c24;padding:3px 10px;border-radius:50px;font-size:.75rem;font-weight:700">⏳ UNPAID</span>
              </c:otherwise>
            </c:choose>
            <c:if test="${not empty o.paymentRef}">
              <br><small style="color:#888;font-size:.7rem">Ref: ${o.paymentRef}</small>
            </c:if>
          </td>
          <td><span class="badge-status badge-${o.status.toLowerCase()}">${o.status}</span></td>
          <td>
            <c:choose>
              <%-- PENDING: Show big Confirm button that triggers payment --%>
              <c:when test="${o.status == 'PENDING'}">
                <form method="post" action="<%=ctx%>/seller/updateOrder"
                      onsubmit="return confirm('Confirm order #${o.id}?\n\nThis will send a payment request of RWF ${o.totalPrice} to:\n${o.buyerName}\n📱 ${o.buyerPhone}\nvia ${o.paymentMethod}')">
                  <input type="hidden" name="orderId" value="${o.id}">
                  <input type="hidden" name="status"  value="CONFIRMED">
                  <button type="submit" style="background:linear-gradient(135deg,#6c63ff,#a855f7);color:#fff;border:none;padding:8px 16px;border-radius:8px;cursor:pointer;font-weight:700;font-size:.82rem;width:100%">
                    ✅ Confirm &amp; Request Payment
                  </button>
                </form>
              </c:when>
              <%-- Other statuses: show dropdown --%>
              <c:otherwise>
                <form method="post" action="<%=ctx%>/seller/updateOrder" class="inline-form">
                  <input type="hidden" name="orderId" value="${o.id}">
                  <select name="status" class="status-select">
                    <option value="CONFIRMED" ${o.status=='CONFIRMED'?'selected':''}>Confirmed ✅</option>
                    <option value="SHIPPED"   ${o.status=='SHIPPED'  ?'selected':''}>Shipped 🚚</option>
                    <option value="DELIVERED" ${o.status=='DELIVERED'?'selected':''}>Delivered 📦</option>
                    <option value="CANCELLED" ${o.status=='CANCELLED'?'selected':''}>Cancel ❌</option>
                  </select>
                  <button type="submit" class="btn-sm btn-update">Update</button>
                </form>
              </c:otherwise>
            </c:choose>
          </td>
        </tr>
        </c:forEach>
        <c:if test="${empty orders}"><tr><td colspan="8" class="text-center">No orders yet.</td></tr></c:if>
        </tbody>
      </table>
      </div>
    </div>

    <%-- VIDEOS TAB --%>
    <div id="tab-videos" class="dash-tab">
      <div class="dash-tab-header">
        <h2><i class="fas fa-play-circle"></i> My Videos — Engagement</h2>
        <a href="<%=ctx%>/seller/uploadVideo" class="btn-primary" style="font-size:.85rem;padding:8px 16px">
          <i class="fas fa-plus"></i> Upload New Video
        </a>
      </div>
      <c:choose>
        <c:when test="${empty myVideos}">
          <div style="text-align:center;padding:40px;color:#aaa">
            <i class="fas fa-video" style="font-size:3rem;display:block;margin-bottom:12px"></i>
            <p>You haven't uploaded any videos yet.</p>
            <a href="<%=ctx%>/seller/uploadVideo" style="color:#6c63ff;font-weight:600">Upload your first video →</a>
          </div>
        </c:when>
        <c:otherwise>
          <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px;padding:8px 0">
            <c:forEach var="vid" items="${myVideos}">
            <div style="background:#fff;border-radius:12px;box-shadow:0 2px 10px rgba(0,0,0,.07);overflow:hidden">
              <div style="background:#111;height:140px;display:flex;align-items:center;justify-content:center;position:relative">
                <video src="<%=ctx%>/uploads/${vid.videoUrl}" style="width:100%;height:140px;object-fit:cover" preload="none"></video>
                <a href="<%=ctx%>/videos" style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;color:#fff;font-size:2rem;background:rgba(0,0,0,.3);text-decoration:none">
                  <i class="fas fa-play-circle"></i>
                </a>
              </div>
              <div style="padding:12px">
                <div style="font-weight:600;font-size:.9rem;margin-bottom:10px;color:#333">${vid.title}</div>
                <div style="display:flex;gap:16px;margin-bottom:10px">
                  <span style="color:#e74c3c;font-weight:700;font-size:1rem">
                    <i class="fas fa-heart"></i> ${vid.likes}
                  </span>
                  <span style="color:#6c63ff;font-weight:700;font-size:1rem">
                    <i class="fas fa-comment-dots"></i> ${vid.commentCount}
                  </span>
                </div>
                <button onclick="loadVideoComments(${vid.id},'${vid.title}')"
                        style="width:100%;background:#f5f3ff;border:1px solid #d8b4fe;border-radius:8px;padding:7px;cursor:pointer;color:#6c63ff;font-size:.82rem;font-weight:600">
                  <i class="fas fa-comments"></i> View Comments
                </button>
              </div>
            </div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </main>
</div>

<%-- Comments viewer modal for seller --%>
<div id="cmtModal" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,.6);align-items:center;justify-content:center">
  <div style="background:#fff;border-radius:16px;width:90%;max-width:500px;max-height:80vh;display:flex;flex-direction:column;overflow:hidden">
    <div style="display:flex;justify-content:space-between;align-items:center;padding:16px 20px;border-bottom:1px solid #f0f0f0">
      <h3 id="cmtModalTitle" style="font-size:1rem;color:#6c63ff">Comments</h3>
      <button onclick="document.getElementById('cmtModal').style.display='none'"
              style="background:none;border:none;font-size:1.2rem;cursor:pointer;color:#999">✕</button>
    </div>
    <div id="cmtModalList" style="flex:1;overflow-y:auto;padding:16px"></div>
  </div>
</div>

<script src="<%=ctx%>/js/main.js"></script>
<script>
function showTab(name,el){
  document.querySelectorAll('.dash-tab').forEach(t=>t.classList.remove('active'));
  document.querySelectorAll('.sidebar-link').forEach(l=>l.classList.remove('active'));
  document.getElementById('tab-'+name).classList.add('active');
  if(el) el.classList.add('active');
}
// Auto-open tab from URL ?tab=xxx
(function(){
  var p = new URLSearchParams(window.location.search);
  var t = p.get('tab');
  if(t && document.getElementById('tab-'+t)){
    document.querySelectorAll('.dash-tab').forEach(x=>x.classList.remove('active'));
    document.getElementById('tab-'+t).classList.add('active');
  }
})();

function loadVideoComments(videoId, title) {
  document.getElementById('cmtModalTitle').textContent = '💬 Comments: ' + title;
  document.getElementById('cmtModalList').innerHTML = '<p style="text-align:center;color:#aaa;padding:20px">Loading…</p>';
  document.getElementById('cmtModal').style.display = 'flex';
  fetch('<%=ctx%>/videos/comment?videoId=' + videoId, {credentials:'same-origin'})
    .then(function(r){ return r.json(); })
    .then(function(list){
      var box = document.getElementById('cmtModalList');
      if (!list || list.length === 0) {
        box.innerHTML = '<p style="text-align:center;color:#aaa;padding:24px"><i class="fas fa-comment-slash"></i><br>No comments yet</p>';
        return;
      }
      box.innerHTML = list.map(function(c){
        var d = c.time ? new Date(c.time).toLocaleDateString() : '';
        return '<div style="display:flex;gap:10px;margin-bottom:14px;padding-bottom:14px;border-bottom:1px solid #f5f5f5">' +
          '<div style="width:36px;height:36px;border-radius:50%;background:#6c63ff;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;flex-shrink:0;font-size:.9rem">'
          + (c.userName||'?').charAt(0).toUpperCase() + '</div>' +
          '<div><div style="font-weight:600;font-size:.82rem;color:#6c63ff">' + escH(c.userName) + '</div>' +
          '<div style="font-size:.88rem;color:#333;margin:2px 0">' + escH(c.comment) + '</div>' +
          '<div style="font-size:.72rem;color:#bbb">' + d + '</div></div></div>';
      }).join('');
    })
    .catch(function(){
      document.getElementById('cmtModalList').innerHTML = '<p style="color:red;padding:20px">Failed to load.</p>';
    });
}
function escH(s){ if(!s)return''; return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
</script>
