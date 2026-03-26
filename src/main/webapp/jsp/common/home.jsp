<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>IDUKA — Rwanda's Online Marketplace</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box}
:root{
  --primary:#FF6A00;
  --primary-light:#fff3ea;
  --dark:#1a1a2e;
  --text:#1c1c1e;
  --muted:#6b7280;
  --border:#e5e7eb;
  --bg:#f5f5f5;
  --white:#fff;
  --radius:8px;
  --shadow:0 1px 4px rgba(0,0,0,.08);
}
body{font-family:'DM Sans',sans-serif;background:var(--bg);color:var(--text);min-height:100vh}

/* ── TOP NAV ── */
.top-nav{background:var(--dark);color:#fff;padding:6px 0;font-size:.75rem}
.top-nav-inner{max-width:1400px;margin:0 auto;padding:0 16px;display:flex;justify-content:space-between;align-items:center}
.top-nav a{color:rgba(255,255,255,.7);text-decoration:none;margin-left:14px}
.top-nav a:hover{color:#fff}

/* ── HEADER ── */
.site-header{background:var(--white);border-bottom:1px solid var(--border);position:sticky;top:0;z-index:100;box-shadow:0 2px 8px rgba(0,0,0,.06)}
.header-inner{max-width:1400px;margin:0 auto;padding:12px 16px;display:flex;align-items:center;gap:16px}
.logo-wrap{display:flex;align-items:center;gap:8px;text-decoration:none;flex-shrink:0}
.logo-icon{width:40px;height:40px;background:var(--primary);border-radius:8px;display:flex;align-items:center;justify-content:center;font-weight:900;font-size:1.1rem;color:#fff}
.logo-text{font-weight:800;font-size:1.35rem;color:var(--dark);letter-spacing:-.5px}

/* Search bar */
.search-wrap{flex:1;display:flex;max-width:680px}
.search-wrap input{flex:1;border:2px solid var(--primary);border-right:none;border-radius:var(--radius) 0 0 var(--radius);padding:0 16px;height:44px;font-size:.9rem;outline:none;font-family:inherit}
.search-wrap button{background:var(--primary);color:#fff;border:none;padding:0 22px;border-radius:0 var(--radius) var(--radius) 0;cursor:pointer;font-size:.95rem;font-weight:700;white-space:nowrap;height:44px}
.search-wrap button:hover{background:#e55f00}

/* Header actions */
.header-actions{display:flex;align-items:center;gap:8px;flex-shrink:0}
.hdr-btn{display:flex;flex-direction:column;align-items:center;gap:2px;padding:6px 10px;border-radius:6px;text-decoration:none;color:var(--text);font-size:.7rem;cursor:pointer;border:none;background:none;transition:background .15s}
.hdr-btn:hover{background:var(--bg)}
.hdr-btn i{font-size:1.2rem;color:var(--muted)}
.hdr-btn.cart i{color:var(--primary)}
.btn-signin{background:var(--primary);color:#fff!important;border-radius:var(--radius);padding:8px 16px;text-decoration:none;font-weight:700;font-size:.85rem;white-space:nowrap}
.btn-signin:hover{background:#e55f00}
.btn-signup{border:1.5px solid var(--primary);color:var(--primary)!important;border-radius:var(--radius);padding:8px 16px;text-decoration:none;font-weight:700;font-size:.85rem;white-space:nowrap}

/* ── CATEGORY BAR ── */
.cat-bar{background:var(--white);border-bottom:1px solid var(--border)}
.cat-bar-inner{max-width:1400px;margin:0 auto;padding:0 16px;display:flex;align-items:center;gap:0;overflow-x:auto;scrollbar-width:none}
.cat-bar-inner::-webkit-scrollbar{display:none}
.cat-item{display:flex;align-items:center;gap:6px;padding:10px 14px;text-decoration:none;color:var(--text);font-size:.82rem;font-weight:500;white-space:nowrap;border-bottom:2px solid transparent;transition:all .15s;flex-shrink:0}
.cat-item:hover,.cat-item.active{color:var(--primary);border-bottom-color:var(--primary)}
.cat-item i{font-size:.9rem}
.cat-all{font-weight:700;color:var(--dark)}

/* ── HERO BANNER ── */
.hero-banner{background:linear-gradient(135deg,#FF6A00 0%,#ff8c38 50%,#ffb347 100%);padding:32px 0;margin-bottom:0}
.hero-inner{max-width:1400px;margin:0 auto;padding:0 16px;display:grid;grid-template-columns:1fr auto;gap:24px;align-items:center}
.hero-text h1{font-size:2rem;font-weight:800;color:#fff;line-height:1.2;margin-bottom:8px}
.hero-text p{color:rgba(255,255,255,.85);font-size:.95rem;margin-bottom:20px}
.hero-btns{display:flex;gap:10px;flex-wrap:wrap}
.hero-btn-main{background:#fff;color:var(--primary);padding:10px 24px;border-radius:50px;font-weight:800;text-decoration:none;font-size:.9rem}
.hero-btn-sec{background:rgba(255,255,255,.2);color:#fff;padding:10px 24px;border-radius:50px;font-weight:700;text-decoration:none;font-size:.9rem;border:1.5px solid rgba(255,255,255,.5)}
.hero-stats{display:flex;gap:24px;flex-shrink:0}
.hero-stat{text-align:center;color:#fff}
.hero-stat strong{display:block;font-size:1.6rem;font-weight:800}
.hero-stat span{font-size:.78rem;opacity:.85}
@media(max-width:600px){.hero-stats{display:none}}

/* ── MAIN LAYOUT ── */
.main-wrap{max-width:1400px;margin:0 auto;padding:16px}

/* ── SECTION TITLE ── */
.sec-head{display:flex;align-items:center;justify-content:space-between;margin:20px 0 12px}
.sec-title{font-size:1.1rem;font-weight:800;color:var(--dark);display:flex;align-items:center;gap:8px}
.sec-title::before{content:'';width:4px;height:20px;background:var(--primary);border-radius:2px;display:inline-block}
.sec-more{font-size:.82rem;color:var(--primary);text-decoration:none;font-weight:600}
.sec-more:hover{text-decoration:underline}

/* ── CATEGORY CARDS ROW ── */
.cat-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(100px,1fr));gap:8px;margin-bottom:20px}
.cat-card{background:var(--white);border-radius:var(--radius);padding:16px 8px;text-align:center;text-decoration:none;color:var(--text);transition:all .2s;border:1px solid var(--border)}
.cat-card:hover{border-color:var(--primary);box-shadow:0 4px 16px rgba(255,106,0,.15);transform:translateY(-2px)}
.cat-card i{font-size:1.5rem;color:var(--primary);display:block;margin-bottom:6px}
.cat-card span{font-size:.75rem;font-weight:600;color:var(--muted)}

/* ── PRODUCT GRID ── */
.products-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px}
@media(max-width:640px){.products-grid{grid-template-columns:repeat(2,1fr);gap:8px}}

/* ── PRODUCT CARD ── */
.prod-card{background:var(--white);border-radius:var(--radius);overflow:hidden;border:1px solid var(--border);transition:all .2s;cursor:pointer;text-decoration:none;color:inherit;display:block}
.prod-card:hover{border-color:#d1d5db;box-shadow:0 6px 24px rgba(0,0,0,.1);transform:translateY(-2px)}
.prod-img-wrap{position:relative;height:200px;background:#f9fafb;overflow:hidden}
.prod-img-wrap img{width:100%;height:100%;object-fit:cover;transition:transform .3s}
.prod-card:hover .prod-img-wrap img{transform:scale(1.04)}
.prod-img-wrap .prod-badge{position:absolute;top:8px;left:8px;background:var(--primary);color:#fff;font-size:.65rem;font-weight:700;padding:2px 8px;border-radius:50px}
.prod-img-wrap .img-placeholder{width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#f3f4f6,#e5e7eb)}
.prod-img-wrap .img-placeholder i{font-size:3rem;color:#d1d5db}
.prod-body{padding:10px 12px 12px}
.prod-name{font-size:.82rem;font-weight:500;color:var(--text);line-height:1.4;margin-bottom:6px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;min-height:38px}
.prod-price{font-size:1.05rem;font-weight:800;color:var(--primary);margin-bottom:4px}
.prod-price-sub{font-size:.72rem;color:var(--muted);margin-bottom:6px}
.prod-seller{font-size:.72rem;color:var(--muted);display:flex;align-items:center;gap:4px;margin-bottom:8px}
.prod-seller i{font-size:.65rem}
.prod-actions{display:flex;gap:6px}
.btn-view{flex:1;background:var(--primary-light);color:var(--primary);border:none;border-radius:6px;padding:7px 0;font-size:.75rem;font-weight:700;cursor:pointer;text-align:center;text-decoration:none;display:block}
.btn-view:hover{background:#ffe0c8}
.btn-chat-sm{background:var(--bg);color:var(--muted);border:none;border-radius:6px;padding:7px 10px;font-size:.75rem;cursor:pointer;text-decoration:none;display:flex;align-items:center;gap:4px}
.btn-chat-sm:hover{background:var(--border)}

/* ── EMPTY STATE ── */
.empty-state{grid-column:1/-1;text-align:center;padding:60px 20px;color:var(--muted)}
.empty-state i{font-size:3rem;display:block;margin-bottom:12px;color:var(--border)}

/* ── FOOTER ── */
.site-footer{background:var(--dark);color:rgba(255,255,255,.7);margin-top:40px;padding:32px 16px}
.footer-inner{max-width:1400px;margin:0 auto;display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:32px}
@media(max-width:768px){.footer-inner{grid-template-columns:1fr 1fr}}
.footer-brand .logo-text{color:#fff;font-size:1.4rem;font-weight:800}
.footer-brand p{margin-top:8px;font-size:.82rem;line-height:1.6}
.footer-col h4{color:#fff;font-weight:700;font-size:.9rem;margin-bottom:12px}
.footer-col a{display:block;color:rgba(255,255,255,.6);text-decoration:none;font-size:.82rem;margin-bottom:8px}
.footer-col a:hover{color:#fff}
.footer-bottom{max-width:1400px;margin:24px auto 0;padding-top:20px;border-top:1px solid rgba(255,255,255,.1);display:flex;justify-content:space-between;align-items:center;font-size:.78rem;flex-wrap:wrap;gap:8px}

/* ── RESPONSIVE HEADER ── */
@media(max-width:768px){
  .header-inner{flex-wrap:wrap;gap:10px}
  .search-wrap{order:3;width:100%;max-width:100%}
  .logo-text{font-size:1.1rem}
  .hdr-btn span{display:none}
  .hero-text h1{font-size:1.4rem}
}
</style>
</head>
<body>

<!-- TOP NAV -->
<div class="top-nav">
  <div class="top-nav-inner">
    <span>🇷🇼 Delivering across Rwanda</span>
    <div>
      <c:choose>
        <c:when test="${not empty sessionScope.user}">
          <a href="<%=ctx%>/profile">My Account</a>
          <a href="<%=ctx%>/logout">Logout</a>
        </c:when>
        <c:otherwise>
          <a href="<%=ctx%>/login">Sign In</a>
          <a href="<%=ctx%>/register">Register</a>
        </c:otherwise>
      </c:choose>
      <a href="<%=ctx%>/videos"><i class="fas fa-video"></i> Product Videos</a>
    </div>
  </div>
</div>

<!-- MAIN HEADER -->
<header class="site-header">
  <div class="header-inner">
    <a href="<%=ctx%>/home" class="logo-wrap">
      <div class="logo-icon">I</div>
      <span class="logo-text">IDUKA</span>
    </a>

    <!-- Search -->
    <form action="<%=ctx%>/home" method="get" class="search-wrap">
      <input type="text" name="search" placeholder="Search products, sellers, categories..." value="${search}" autocomplete="off">
      <button type="submit"><i class="fas fa-search"></i> Search</button>
    </form>

    <!-- Actions -->
    <div class="header-actions">
      <c:choose>
        <c:when test="${not empty sessionScope.user}">
          <a href="<%=ctx%>/chat/inbox" class="hdr-btn">
            <i class="fas fa-comments"></i><span>Messages</span>
          </a>
          <a href="<%=ctx%>/videos" class="hdr-btn">
            <i class="fas fa-play-circle"></i><span>Videos</span>
          </a>
          <c:choose>
            <c:when test="${sessionScope.userRole == 'SELLER'}">
              <a href="<%=ctx%>/seller/dashboard" class="btn-signin">My Shop</a>
            </c:when>
            <c:otherwise>
              <a href="<%=ctx%>/buyer/order" class="btn-signin">My Orders</a>
            </c:otherwise>
          </c:choose>
        </c:when>
        <c:otherwise>
          <a href="<%=ctx%>/login" class="btn-signup">Sign In</a>
          <a href="<%=ctx%>/register" class="btn-signin">Create Account</a>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</header>

<!-- CATEGORY BAR -->
<div class="cat-bar">
  <div class="cat-bar-inner">
    <a href="<%=ctx%>/home" class="cat-item cat-all"><i class="fas fa-th-large"></i> All Categories</a>
    <c:forEach var="cat" items="${categories}">
      <a href="<%=ctx%>/home?catId=${cat.id}" class="cat-item <c:if test="${param.catId == cat.id}">active</c:if>">
        <i class="${cat.iconClass}"></i> ${cat.name}
      </a>
    </c:forEach>
  </div>
</div>

<!-- HERO BANNER (only for guests) -->
<c:if test="${empty sessionScope.user}">
<div class="hero-banner">
  <div class="hero-inner">
    <div class="hero-text">
      <h1>Rwanda's Digital Marketplace</h1>
      <p>Buy & sell from anywhere in Rwanda. No shop rent. No limits.</p>
      <div class="hero-btns">
        <a href="<%=ctx%>/register" class="hero-btn-main"><i class="fas fa-store"></i> Start Selling</a>
        <a href="<%=ctx%>/register" class="hero-btn-sec"><i class="fas fa-shopping-bag"></i> Shop Now</a>
      </div>
    </div>
    <div class="hero-stats">
      <div class="hero-stat"><strong>500+</strong><span>Sellers</span></div>
      <div class="hero-stat"><strong>2K+</strong><span>Products</span></div>
      <div class="hero-stat"><strong>5K+</strong><span>Buyers</span></div>
    </div>
  </div>
</div>
</c:if>

<!-- MAIN CONTENT -->
<div class="main-wrap">

  <!-- Categories Grid -->
  <c:if test="${empty search and empty param.catId}">
  <div class="sec-head">
    <span class="sec-title">Shop by Category</span>
    <a href="<%=ctx%>/home" class="sec-more">View all →</a>
  </div>
  <div class="cat-grid">
    <c:forEach var="cat" items="${categories}">
    <a href="<%=ctx%>/home?catId=${cat.id}" class="cat-card">
      <i class="${cat.iconClass}"></i>
      <span>${cat.name}</span>
    </a>
    </c:forEach>
  </div>
  </c:if>

  <!-- Products Section -->
  <div class="sec-head">
    <span class="sec-title">
      <c:choose>
        <c:when test="${not empty search}">Results for "<c:out value="${search}"/>"</c:when>
        <c:when test="${not empty param.catId}">
          <c:forEach var="cat" items="${categories}">
            <c:if test="${cat.id == param.catId}">${cat.name}</c:if>
          </c:forEach>
        </c:when>
        <c:otherwise>Latest Products</c:otherwise>
      </c:choose>
    </span>
    <a href="<%=ctx%>/videos" class="sec-more"><i class="fas fa-video"></i> Watch Videos</a>
  </div>

  <div class="products-grid">
    <c:forEach var="product" items="${products}">
    <a href="<%=ctx%>/product?id=${product.id}" class="prod-card">
      <div class="prod-img-wrap">
        <c:choose>
          <c:when test="${not empty product.imageUrl and not fn:startsWith(product.imageUrl, 'http')}">
            <img src="<%=ctx%>/uploads/${product.imageUrl}" alt="${product.name}"
                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
            <div class="img-placeholder" style="display:none"><i class="fas fa-image"></i></div>
          </c:when>
          <c:when test="${not empty product.imageUrl and fn:startsWith(product.imageUrl, 'http')}">
            <img src="${product.imageUrl}" alt="${product.name}"
                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
            <div class="img-placeholder" style="display:none"><i class="fas fa-image"></i></div>
          </c:when>
          <c:otherwise>
            <div class="img-placeholder"><i class="fas fa-image"></i></div>
          </c:otherwise>
        </c:choose>
        <c:if test="${product.stock > 0 and product.stock <= 5}">
          <span class="prod-badge">Only ${product.stock} left</span>
        </c:if>
        <c:if test="${product.stock == 0}">
          <span class="prod-badge" style="background:#6b7280">Out of stock</span>
        </c:if>
      </div>
      <div class="prod-body">
        <div class="prod-name">${product.name}</div>
        <div class="prod-price">RWF <fmt:formatNumber value="${product.price}" pattern="#,###"/></div>
        <div class="prod-price-sub">
          <c:if test="${product.stock > 0}">In stock: ${product.stock} available</c:if>
        </div>
        <div class="prod-seller"><i class="fas fa-store"></i> ${product.sellerName}</div>
        <div class="prod-actions" onclick="event.preventDefault()">
          <a href="<%=ctx%>/product?id=${product.id}" class="btn-view">View Details</a>
          <c:if test="${sessionScope.userRole == 'BUYER'}">
            <a href="<%=ctx%>/chat?userId=${product.sellerId}&productId=${product.id}" class="btn-chat-sm">
              <i class="fas fa-comment"></i>
            </a>
          </c:if>
        </div>
      </div>
    </a>
    </c:forEach>

    <c:if test="${empty products}">
      <div class="empty-state">
        <i class="fas fa-search"></i>
        <p style="font-weight:600;color:#374151;margin-bottom:6px">No products found</p>
        <p style="font-size:.85rem">Try searching for something else or browse categories</p>
        <a href="<%=ctx%>/home" style="display:inline-block;margin-top:16px;background:var(--primary);color:#fff;padding:10px 24px;border-radius:50px;text-decoration:none;font-weight:700">Browse All Products</a>
      </div>
    </c:if>
  </div>
</div>

<!-- FOOTER -->
<footer class="site-footer">
  <div class="footer-inner">
    <div class="footer-brand">
      <div class="logo-text">IDUKA</div>
      <p>Rwanda's trusted online marketplace connecting buyers and sellers across all provinces.</p>
    </div>
    <div class="footer-col">
      <h4>Marketplace</h4>
      <a href="<%=ctx%>/home">Home</a>
      <a href="<%=ctx%>/videos">Product Videos</a>
      <a href="<%=ctx%>/register">Sell on IDUKA</a>
    </div>
    <div class="footer-col">
      <h4>Account</h4>
      <a href="<%=ctx%>/login">Sign In</a>
      <a href="<%=ctx%>/register">Register</a>
      <a href="<%=ctx%>/profile">My Profile</a>
    </div>
    <div class="footer-col">
      <h4>Support</h4>
      <a href="<%=ctx%>/chat/inbox">Messages</a>
      <c:if test="${sessionScope.userRole == 'BUYER'}">
        <a href="<%=ctx%>/buyer/order">My Orders</a>
      </c:if>
      <c:if test="${sessionScope.userRole == 'SELLER'}">
        <a href="<%=ctx%>/seller/dashboard">My Shop</a>
      </c:if>
    </div>
  </div>
  <div class="footer-bottom">
    <span>© 2025 IDUKA Marketplace — Empowering Rwanda's Youth</span>
    <span>🇷🇼 Made in Rwanda</span>
  </div>
</footer>

<script src="<%=ctx%>/js/main.js"></script>
<script>
// Highlight active category
document.querySelectorAll('.cat-item').forEach(function(a) {
  if (a.href === window.location.href) a.classList.add('active');
});
</script>
</body>
</html>
