<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>IDUKA - Rwanda's Online Marketplace</title>
<jsp:include page="css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="header.jsp"/>

<c:if test="${empty sessionScope.user}">
<section class="hero">
  <div class="hero-content">
    <h1>Rwanda's Digital Marketplace</h1>
    <p>Buy &amp; sell from anywhere in Rwanda. No shop rent. No boundaries.</p>
    <div class="hero-btns">
      <a href="<%=ctx%>/register" class="btn-hero-seller"><i class="fas fa-store"></i> Open Your Shop</a>
      <a href="<%=ctx%>/register" class="btn-hero-buyer"><i class="fas fa-shopping-cart"></i> Start Shopping</a>
    </div>
  </div>
  <div class="hero-stats">
    <div class="stat"><i class="fas fa-store"></i><strong>500+</strong><span>Sellers</span></div>
    <div class="stat"><i class="fas fa-box"></i><strong>2000+</strong><span>Products</span></div>
    <div class="stat"><i class="fas fa-users"></i><strong>5000+</strong><span>Buyers</span></div>
  </div>
</section>
</c:if>

<section class="section-wrap">
  <h2 class="section-title">Shop by Category</h2>
  <div class="categories-grid">
    <c:forEach var="cat" items="${categories}">
    <a href="<%=ctx%>/home?catId=${cat.id}" class="category-card">
      <i class="${cat.iconClass}"></i><span>${cat.name}</span>
    </a>
    </c:forEach>
  </div>
</section>

<section class="section-wrap">
  <div class="section-header">
    <h2 class="section-title">
      <c:choose>
        <c:when test="${not empty search}">Results for "<c:out value="${search}"/>"</c:when>
        <c:otherwise>Latest Products</c:otherwise>
      </c:choose>
    </h2>
    <a href="<%=ctx%>/videos" class="btn-outline-sm"><i class="fas fa-video"></i> Watch Videos</a>
  </div>
  <div class="products-grid">
    <c:forEach var="product" items="${products}">
    <div class="product-card">
      <a href="<%=ctx%>/product?id=${product.id}" class="product-img-link">
        <c:choose>
          <c:when test="${empty product.imageUrl}">
            <img src="<%=ctx%>/images/no-image.svg" alt="${product.name}" style="width:100%;height:200px;object-fit:cover">
          </c:when>
          <c:otherwise>
            <img src="<%=ctx%>/uploads/${product.imageUrl}" alt="${product.name}"
                 style="width:100%;height:200px;object-fit:cover;background:#f5f7fa"
                 onerror="this.onerror=null;this.src='<%=ctx%>/images/no-image.svg'">
          </c:otherwise>
        </c:choose>
        <div class="product-overlay"><i class="fas fa-eye"></i> View</div>
      </a>
      <div class="product-info">
        <h3 class="product-name"><a href="<%=ctx%>/product?id=${product.id}">${product.name}</a></h3>
        <p class="product-seller"><i class="fas fa-store"></i> ${product.sellerName}</p>
        <div class="product-bottom">
          <span class="product-price">RWF ${product.price}</span>
          <c:choose>
            <c:when test="${sessionScope.userRole == 'BUYER'}">
              <a href="<%=ctx%>/product?id=${product.id}" class="btn-order-sm">Order</a>
            </c:when>
            <c:when test="${empty sessionScope.user}">
              <a href="<%=ctx%>/login" class="btn-order-sm">Login to Buy</a>
            </c:when>
          </c:choose>
        </div>
        <c:if test="${sessionScope.userRole == 'BUYER'}">
          <a href="<%=ctx%>/chat?userId=${product.sellerId}&productId=${product.id}" class="btn-chat-sm">
            <i class="fas fa-comment"></i> Chat with Seller
          </a>
        </c:if>
      </div>
    </div>
    </c:forEach>
    <c:if test="${empty products}">
      <div class="empty-state"><i class="fas fa-search fa-3x"></i><p>No products found.</p></div>
    </c:if>
  </div>
</section>

<footer class="main-footer">
  <div class="footer-inner">
    <div class="footer-brand"><div class="logo-mark sm">I</div><span>IDUKA</span></div>
    <p>Empowering Rwanda's youth through digital commerce &copy; 2025</p>
    <div class="footer-links">
      <a href="<%=ctx%>/home">Home</a>
      <a href="<%=ctx%>/videos">Videos</a>
      <a href="<%=ctx%>/register">Join</a>
    </div>
  </div>
</footer>
<script src="<%=ctx%>/js/main.js"></script>
</body>
</html>
