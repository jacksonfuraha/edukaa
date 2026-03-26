<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); pageContext.setAttribute("ctx", ctx); %>
<header class="main-header">
  <div class="header-inner">
    <a href="<%=ctx%>/home" class="logo">
      <div class="logo-mark">I</div><span>IDUKA</span>
    </a>
    <form action="<%=ctx%>/home" method="get" class="search-bar">
      <input type="text" name="search" placeholder="Search products, shops..." value="${search}">
      <button type="submit"><i class="fas fa-search"></i></button>
    </form>
    <nav class="header-nav">
      <a href="<%=ctx%>/videos" class="nav-link"><i class="fas fa-play-circle"></i> Videos</a>
      <c:choose>
        <c:when test="${not empty sessionScope.user}">

          <%-- CHAT with unread badge --%>
          <a href="<%=ctx%>/chat/inbox" class="nav-link" id="chatLink" title="Messages" style="position:relative;display:inline-flex;align-items:center;gap:6px;">
            <span style="position:relative;display:inline-flex;align-items:center;">
              <i class="fas fa-comments" style="font-size:1.15rem;"></i>
              <span class="hdr-badge hidden" id="chatBadge">0</span>
            </span>
            Chats
          </a>

          <c:if test="${sessionScope.userRole == 'SELLER'}">
            <a href="<%=ctx%>/seller/dashboard" class="nav-link" style="position:relative;display:inline-flex;align-items:center;gap:6px;">
              <span style="position:relative;display:inline-flex;align-items:center;">
                <i class="fas fa-store" style="font-size:1.15rem;"></i>
                <span class="hdr-badge hidden" id="orderBadge">0</span>
              </span>
              My Shop
            </a>
          </c:if>
          <c:if test="${sessionScope.userRole == 'BUYER'}">
            <a href="<%=ctx%>/buyer/order" class="nav-link" style="position:relative;display:inline-flex;align-items:center;gap:6px;">
              <span style="position:relative;display:inline-flex;align-items:center;">
                <i class="fas fa-box" style="font-size:1.15rem;"></i>
                <span class="hdr-badge hidden" id="orderBadge">0</span>
              </span>
              Orders
            </a>
          </c:if>

          <%-- NOTIFICATION BELL --%>
          <div class="notif-bell-wrap" id="notifBell">
              <button class="notif-bell-btn" id="notifBellBtn" title="Notifications" style="position:relative;">
                <i class="fas fa-bell" style="font-size:1.2rem;pointer-events:none;"></i>
                <span class="hdr-badge hidden" id="notifBadge">0</span>
              </button>
            <div class="notif-dropdown" id="notifDropdown">
              <div class="notif-header">
                <span><i class="fas fa-bell"></i> Notifications</span>
                <button class="notif-mark-all" id="notifMarkAllBtn">
                  <i class="fas fa-check-double"></i> Mark all read
                </button>
              </div>
              <div class="notif-list" id="notifList">
                <div class="notif-empty">
                  <i class="fas fa-bell-slash"></i>
                  <p>No new notifications</p>
                </div>
              </div>
              <div class="notif-footer">
                <c:choose>
                  <c:when test="${sessionScope.userRole == 'SELLER'}">
                    <a href="<%=ctx%>/seller/dashboard"><i class="fas fa-store"></i> Go to Dashboard</a>
                  </c:when>
                  <c:otherwise>
                    <a href="<%=ctx%>/buyer/order"><i class="fas fa-box"></i> View My Orders</a>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <div class="user-menu">
            <button class="user-btn">
              <c:choose>
                <c:when test="${not empty sessionScope.user.avatarUrl}">
                  <img src="<%=ctx%>/uploads/${sessionScope.user.avatarUrl}" class="user-avatar-sm" alt="avatar">
                </c:when>
                <c:otherwise><i class="fas fa-user-circle"></i></c:otherwise>
              </c:choose>
              ${sessionScope.userName} <i class="fas fa-caret-down"></i>
            </button>
            <div class="user-dropdown">
              <c:if test="${sessionScope.user.id == 1}">
                <a href="<%=ctx%>/admin/sellers" style="color:#6c63ff"><i class="fas fa-shield-alt"></i> Admin Panel</a>
              </c:if>
              <a href="<%=ctx%>/profile"><i class="fas fa-cog"></i> Profile Settings</a>
              <a href="<%=ctx%>/logout" style="color:#e74c3c"><i class="fas fa-sign-out-alt"></i> Logout</a>
            </div>
          </div>
        </c:when>
        <c:otherwise>
          <a href="<%=ctx%>/login" class="btn-login">Login</a>
          <a href="<%=ctx%>/register" class="btn-register">Register</a>
        </c:otherwise>
      </c:choose>
    </nav>
    <button class="hamburger" onclick="toggleMenu()"><i class="fas fa-bars"></i></button>
  </div>
  <%-- Dropdown mobile nav (hamburger) --%>
  <nav class="mobile-nav" id="mobileNav">
    <a href="<%=ctx%>/home"><i class="fas fa-home"></i> Home</a>
    <a href="<%=ctx%>/videos"><i class="fas fa-play-circle"></i> Videos</a>
    <c:choose>
      <c:when test="${not empty sessionScope.user}">
        <a href="<%=ctx%>/chat/inbox" class="mobile-nav-badge-link">
          <i class="fas fa-comments"></i> Chats
          <span class="mob-nav-badge hidden" id="mobChatBadge">0</span>
        </a>
        <a href="<%=ctx%>/notifications" class="mobile-nav-badge-link">
          <i class="fas fa-bell"></i> Notifications
          <span class="mob-nav-badge hidden" id="mobNotifBadge">0</span>
        </a>
        <c:if test="${sessionScope.userRole == 'SELLER'}"><a href="<%=ctx%>/seller/dashboard"><i class="fas fa-store"></i> My Shop</a></c:if>
        <c:if test="${sessionScope.userRole == 'BUYER'}"><a href="<%=ctx%>/buyer/order"><i class="fas fa-box"></i> Orders</a></c:if>
        <a href="<%=ctx%>/profile"><i class="fas fa-user-cog"></i> Profile Settings</a>
        <a href="<%=ctx%>/logout" style="color:#e74c3c"><i class="fas fa-sign-out-alt"></i> Logout</a>
      </c:when>
      <c:otherwise>
        <a href="<%=ctx%>/login"><i class="fas fa-sign-in-alt"></i> Login</a>
        <a href="<%=ctx%>/register"><i class="fas fa-user-plus"></i> Register</a>
      </c:otherwise>
    </c:choose>
  </nav>

  <%-- Bottom navigation bar for mobile (always visible) --%>
  <c:if test="${not empty sessionScope.user}">
  <nav class="mobile-bottom-nav">
    <a href="<%=ctx%>/home" class="mob-btn">
      <i class="fas fa-home"></i><span>Home</span>
    </a>
    <a href="<%=ctx%>/videos" class="mob-btn">
      <i class="fas fa-play-circle"></i><span>Videos</span>
    </a>
    <a href="<%=ctx%>/chat/inbox" class="mob-btn" style="position:relative">
      <i class="fas fa-comments"></i>
      <span class="mob-bottom-badge hidden" id="mobBotChatBadge">0</span>
      <span>Chats</span>
    </a>
    <button class="mob-btn" id="mobBellBtn" style="background:none;border:none;cursor:pointer;position:relative">
      <i class="fas fa-bell"></i>
      <span class="mob-bottom-badge hidden" id="mobBotNotifBadge">0</span>
      <span>Alerts</span>
    </button>
    <c:choose>
      <c:when test="${sessionScope.userRole == 'SELLER'}">
        <a href="<%=ctx%>/seller/dashboard" class="mob-btn">
          <i class="fas fa-store"></i><span>Shop</span>
        </a>
      </c:when>
      <c:otherwise>
        <a href="<%=ctx%>/buyer/order" class="mob-btn">
          <i class="fas fa-box"></i><span>Orders</span>
        </a>
      </c:otherwise>
    </c:choose>
  </nav>
  <%-- Notification dropdown for mobile bell --%>
  <div class="mob-notif-overlay hidden" id="mobNotifOverlay">
    <div class="mob-notif-sheet" id="mobNotifSheet">
      <div class="mob-notif-header">
        <span><i class="fas fa-bell"></i> Notifications</span>
        <button onclick="document.getElementById('mobNotifOverlay').classList.add('hidden')" style="background:none;border:none;color:#fff;font-size:1.2rem;cursor:pointer">&#x2715;</button>
      </div>
      <div class="notif-list" id="mobNotifList">
        <div class="notif-empty"><i class="fas fa-bell-slash"></i><p>No new notifications</p></div>
      </div>
      <div style="padding:12px;text-align:center;border-top:1px solid #f0eeff">
        <c:choose>
          <c:when test="${sessionScope.userRole == 'SELLER'}">
            <a href="<%=ctx%>/seller/dashboard" style="color:#6c63ff;font-weight:600;text-decoration:none"><i class="fas fa-store"></i> Go to Dashboard</a>
          </c:when>
          <c:otherwise>
            <a href="<%=ctx%>/buyer/order" style="color:#6c63ff;font-weight:600;text-decoration:none"><i class="fas fa-box"></i> View My Orders</a>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
  </c:if>
</header>

<c:if test="${not empty sessionScope.user}">
<script>
window.IDUKA_CTX = '<%=ctx%>';
(function () {
  function init() {
    var bellBtn  = document.getElementById('notifBellBtn');
    var markBtn  = document.getElementById('notifMarkAllBtn');
    var dropdown = document.getElementById('notifDropdown');
    var bellWrap = document.getElementById('notifBell');
    if (!bellBtn || !dropdown) return;

    bellBtn.addEventListener('click', function (e) {
      e.preventDefault(); e.stopPropagation();
      var isOpen = dropdown.classList.toggle('open');
      if (isOpen && window._markAllRead) window._markAllRead();
    });
    markBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      if (window._markAllRead) window._markAllRead();
      dropdown.classList.remove('open');
    });
    dropdown.addEventListener('click', function (e) { e.stopPropagation(); });
    document.addEventListener('click', function (e) {
      if (bellWrap && !bellWrap.contains(e.target)) dropdown.classList.remove('open');
    });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
  else init();

  // Mobile bell button → open notification sheet
  function initMobile() {
    var mobBell    = document.getElementById('mobBellBtn');
    var mobOverlay = document.getElementById('mobNotifOverlay');
    if (mobBell && mobOverlay) {
      mobBell.addEventListener('click', function() {
        mobOverlay.classList.remove('hidden');
        if (window._markAllRead) window._markAllRead();
      });
      mobOverlay.addEventListener('click', function(e) {
        if (e.target === mobOverlay) mobOverlay.classList.add('hidden');
      });
    }
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initMobile);
  else initMobile();
})();
</script>
<script src="<%=ctx%>/js/notifications.js"></script>
</c:if>
