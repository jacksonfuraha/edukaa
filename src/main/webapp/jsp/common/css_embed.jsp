<%@ page contentType="text/html;charset=UTF-8" %>
<style>
/* ==============================
   IDUKA - Main Stylesheet
   Rwanda Online Marketplace
   ============================== */

:root {
  --primary: #6c63ff;
  --primary-dark: #4b44cc;
  --secondary: #ff6584;
  --accent: #43e97b;
  --dark: #1a1a2e;
  --dark2: #16213e;
  --text: #333;
  --text-light: #666;
  --bg: #f5f7fa;
  --white: #fff;
  --border: #e0e0e0;
  --shadow: 0 4px 20px rgba(0,0,0,0.08);
  --shadow-hover: 0 8px 30px rgba(108,99,255,0.2);
  --radius: 12px;
  --radius-sm: 8px;
}

* { margin:0; padding:0; box-sizing:border-box; }
html { scroll-behavior:smooth; }
body { font-family:'Segoe UI',system-ui,sans-serif; background:var(--bg); color:var(--text); line-height:1.6; }


/* ===== FORM VALIDATION STYLES ===== */
.field-error {
  color: #e74c3c;
  font-size: .78rem;
  margin-top: 4px;
  display: flex;
  align-items: center;
  gap: 5px;
  font-weight: 500;
  animation: shake .3s ease;
}
@keyframes shake {
  0%,100% { transform: translateX(0); }
  25%      { transform: translateX(-5px); }
  75%      { transform: translateX(5px); }
}
.input-error {
  border-color: #e74c3c !important;
  background: #fff5f5 !important;
  box-shadow: 0 0 0 3px rgba(231,76,60,.12) !important;
}
.input-ok {
  border-color: #27ae60 !important;
  background: #f0fff4 !important;
  box-shadow: 0 0 0 3px rgba(39,174,96,.1) !important;
}
/* password strength bar */
.pw-strength-wrap { margin-top: 6px; }
.pw-strength-bar {
  height: 4px; border-radius: 50px;
  background: #e0e0e0; overflow: hidden;
}
.pw-strength-fill {
  height: 100%; border-radius: 50px;
  transition: width .3s, background .3s;
  width: 0%;
}
.pw-strength-text { font-size: .72rem; margin-top: 3px; font-weight: 600; }

/* ===== HEADER ===== */
.main-header { background:var(--white); box-shadow:0 2px 12px rgba(0,0,0,0.08); position:sticky; top:0; z-index:1000; }
.header-inner { max-width:1280px; margin:0 auto; padding:0 20px; height:65px; display:flex; align-items:center; gap:16px; }
.logo { display:flex; align-items:center; gap:10px; text-decoration:none; flex-shrink:0; }
.logo-mark { width:36px; height:36px; background:linear-gradient(135deg,var(--primary),var(--secondary)); border-radius:10px; display:flex; align-items:center; justify-content:center; color:#fff; font-weight:900; font-size:1.1rem; }
.logo-mark.sm { width:28px; height:28px; font-size:0.9rem; border-radius:8px; }
.logo span { font-size:1.4rem; font-weight:800; background:linear-gradient(135deg,var(--primary),var(--secondary)); -webkit-background-clip:text; -webkit-text-fill-color:transparent; }
.search-bar { flex:1; max-width:500px; display:flex; background:var(--bg); border:2px solid var(--border); border-radius:50px; overflow:hidden; transition:border 0.2s; }
.search-bar:focus-within { border-color:var(--primary); }
.search-bar input { flex:1; border:none; background:transparent; padding:10px 16px; outline:none; font-size:0.95rem; }
.search-bar button { background:var(--primary); color:#fff; border:none; padding:0 20px; cursor:pointer; font-size:1rem; }
.header-nav { display:flex; align-items:center; gap:8px; margin-left:auto; }
.nav-link { text-decoration:none; color:var(--text); padding:8px 12px; border-radius:8px; font-size:0.9rem; transition:all 0.2s; }
.nav-link:hover { background:var(--bg); color:var(--primary); }
.btn-login { background:transparent; border:2px solid var(--primary); color:var(--primary); padding:7px 18px; border-radius:50px; text-decoration:none; font-weight:600; font-size:0.9rem; transition:all 0.2s; }
.btn-login:hover { background:var(--primary); color:#fff; }
.btn-register { background:linear-gradient(135deg,var(--primary),var(--secondary)); color:#fff; padding:7px 18px; border-radius:50px; text-decoration:none; font-weight:600; font-size:0.9rem; transition:all 0.2s; }
.btn-register:hover { opacity:0.85; transform:translateY(-1px); }
.user-menu { position:relative; }
.user-btn {
  background:none; border:none; cursor:pointer; color:var(--text);
  font-size:0.9rem; padding:6px 10px; border-radius:8px; font-family:inherit;
  display:inline-flex; align-items:center; gap:6px;
  overflow:hidden; max-height:48px;
}
.user-avatar-sm {
  width:32px !important; height:32px !important;
  min-width:32px !important; max-width:32px !important;
  min-height:32px !important; max-height:32px !important;
  border-radius:50% !important;
  object-fit:cover !important;
  object-position:center top !important;
  border:2px solid #6c63ff !important;
  display:inline-block !important;
  flex-shrink:0 !important;
  vertical-align:middle !important;
}
.user-dropdown { display:none; position:absolute; right:0; top:100%; background:#fff; border:1px solid var(--border); border-radius:var(--radius-sm); padding:8px; min-width:160px; box-shadow:var(--shadow); z-index:999; }
.user-menu:hover .user-dropdown { display:block; }
.user-dropdown a { display:block; padding:8px 12px; text-decoration:none; color:var(--text); border-radius:6px; font-size:0.9rem; }
.user-dropdown a:hover { background:var(--bg); color:var(--primary); }
.hamburger { display:none; background:none; border:none; font-size:1.3rem; cursor:pointer; color:var(--text); padding:8px; }
.mobile-nav { display:none; flex-direction:column; background:#fff; border-top:1px solid var(--border); padding:12px; }
.mobile-nav a { padding:12px 16px; text-decoration:none; color:var(--text); border-radius:8px; display:flex; align-items:center; gap:10px; font-size:.95rem; }
.mobile-nav a:hover { background:var(--bg); }
.mobile-nav.open { display:flex; }
.mobile-nav-badge-link { position:relative; }
.mob-nav-badge {
  background:#e74c3c; color:#fff; font-size:.62rem; font-weight:800;
  border-radius:50px; padding:1px 6px; margin-left:6px;
}
.mob-nav-badge.hidden { display:none !important; }

/* ── MOBILE BOTTOM NAV BAR ── */
.mobile-bottom-nav {
  display: none;
  position: fixed;
  bottom: 0; left: 0; right: 0;
  height: 62px;
  background: #fff;
  border-top: 1px solid #e8e8e8;
  box-shadow: 0 -4px 20px rgba(0,0,0,.08);
  z-index: 9998;
  justify-content: space-around;
  align-items: center;
  padding: 0 4px;
}
@media (max-width: 768px) {
  .mobile-bottom-nav { display: flex; }
  body { padding-bottom: 66px; } /* stop content hiding behind bar */
}
.mob-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  text-decoration: none;
  color: #888;
  font-size: .65rem;
  font-weight: 600;
  padding: 6px 10px;
  border-radius: 12px;
  min-width: 52px;
  transition: color .2s, background .2s;
  font-family: Arial, sans-serif;
}
.mob-btn i { font-size: 1.25rem; }
.mob-btn:hover, .mob-btn.active { color: #6c63ff; }
.mob-bottom-badge {
  position: absolute;
  top: 2px; right: 4px;
  min-width: 17px; height: 17px;
  background: #e74c3c; color: #fff;
  font-size: .58rem; font-weight: 900;
  border-radius: 50px;
  display: flex; align-items: center; justify-content: center;
  padding: 0 3px;
  border: 2px solid #fff;
  pointer-events: none;
}
.mob-bottom-badge.hidden { display: none !important; }

/* ── MOBILE NOTIFICATION SHEET (slides up) ── */
.mob-notif-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,.45);
  z-index: 99999;
  display: flex;
  align-items: flex-end;
}
.mob-notif-overlay.hidden { display: none !important; }
.mob-notif-sheet {
  width: 100%;
  max-height: 75vh;
  background: #fff;
  border-radius: 20px 20px 0 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  animation: slideUp .25s ease;
}
@keyframes slideUp {
  from { transform: translateY(100%); }
  to   { transform: translateY(0); }
}
.mob-notif-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: linear-gradient(135deg,#6c63ff,#a855f7);
  color: #fff;
  font-weight: 700;
  font-size: 1rem;
  flex-shrink: 0;
}

/* ===== HERO ===== */
.hero { background:linear-gradient(135deg,var(--dark) 0%,var(--dark2) 50%,#0f3460 100%); color:#fff; padding:70px 20px 50px; text-align:center; position:relative; overflow:hidden; }
.hero::before { content:''; position:absolute; top:-50%; left:-50%; width:200%; height:200%; background:radial-gradient(circle,rgba(108,99,255,0.15) 0%,transparent 60%); }
.hero-content { max-width:700px; margin:0 auto; position:relative; }
.hero h1 { font-size:2.8rem; font-weight:900; margin-bottom:16px; line-height:1.2; }
.hero p { font-size:1.1rem; color:rgba(255,255,255,0.8); margin-bottom:32px; }
.hero-btns { display:flex; gap:16px; justify-content:center; flex-wrap:wrap; }
.btn-hero-seller { background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; padding:14px 32px; border-radius:50px; text-decoration:none; font-weight:700; font-size:1rem; transition:all 0.2s; }
.btn-hero-seller:hover { transform:translateY(-2px); box-shadow:0 8px 25px rgba(108,99,255,0.4); }
.btn-hero-buyer { background:linear-gradient(135deg,var(--secondary),#ff4757); color:#fff; padding:14px 32px; border-radius:50px; text-decoration:none; font-weight:700; font-size:1rem; transition:all 0.2s; }
.btn-hero-buyer:hover { transform:translateY(-2px); box-shadow:0 8px 25px rgba(255,101,132,0.4); }
.hero-stats { display:flex; justify-content:center; gap:40px; margin-top:50px; flex-wrap:wrap; position:relative; }
.stat { text-align:center; }
.stat i { font-size:1.8rem; color:var(--primary); display:block; margin-bottom:6px; }
.stat strong { display:block; font-size:1.5rem; font-weight:800; }
.stat span { font-size:0.85rem; color:rgba(255,255,255,0.6); }

/* ===== SECTIONS ===== */
.section-wrap { max-width:1280px; margin:0 auto; padding:40px 20px; }
.section-title { font-size:1.5rem; font-weight:700; margin-bottom:24px; color:var(--dark); }
.section-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
.btn-outline-sm { padding:8px 16px; border:2px solid var(--primary); color:var(--primary); border-radius:50px; text-decoration:none; font-size:0.85rem; font-weight:600; }
.btn-outline-sm:hover { background:var(--primary); color:#fff; }

/* ===== CATEGORIES ===== */
.categories-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(110px,1fr)); gap:12px; }
.category-card { display:flex; flex-direction:column; align-items:center; gap:8px; padding:16px 8px; background:#fff; border-radius:var(--radius); text-decoration:none; color:var(--text); transition:all 0.2s; border:2px solid transparent; }
.category-card:hover { border-color:var(--primary); color:var(--primary); transform:translateY(-2px); box-shadow:var(--shadow); }
.category-card i { font-size:1.5rem; color:var(--primary); }
.category-card span { font-size:0.8rem; font-weight:600; text-align:center; }

/* ===== PRODUCTS GRID ===== */
.products-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(240px,1fr)); gap:20px; }
.product-card { background:#fff; border-radius:var(--radius); overflow:hidden; box-shadow:var(--shadow); transition:all 0.25s; }
.product-card:hover { transform:translateY(-4px); box-shadow:var(--shadow-hover); }
.product-img-link { display:block; position:relative; overflow:hidden; height:200px; }
.product-img-link img { width:100%; height:100%; object-fit:cover; transition:transform 0.3s; }
.product-card:hover .product-img-link img { transform:scale(1.06); }
.product-overlay { position:absolute; inset:0; background:rgba(108,99,255,0.7); color:#fff; display:flex; align-items:center; justify-content:center; font-size:1rem; font-weight:600; opacity:0; transition:opacity 0.2s; }
.product-card:hover .product-overlay { opacity:1; }
.product-info { padding:14px; }
.product-name { font-size:0.95rem; font-weight:700; margin-bottom:4px; }
.product-name a { text-decoration:none; color:var(--dark); }
.product-seller { font-size:0.8rem; color:var(--text-light); margin-bottom:10px; }
.product-bottom { display:flex; align-items:center; justify-content:space-between; margin-bottom:8px; }
.product-price { font-size:1rem; font-weight:800; color:var(--primary); }
.btn-order-sm { background:var(--primary); color:#fff; padding:5px 12px; border-radius:50px; text-decoration:none; font-size:0.78rem; font-weight:600; }
.btn-chat-sm { display:block; background:var(--bg); color:var(--text-light); padding:6px 10px; border-radius:8px; text-decoration:none; font-size:0.8rem; text-align:center; border:1px solid var(--border); transition:all 0.2s; }
.btn-chat-sm:hover { background:var(--primary); color:#fff; border-color:var(--primary); }

/* ===== PRODUCT DETAIL ===== */
.container { max-width:1200px; margin:0 auto; padding:0 20px; }
.mt-4 { margin-top:32px; }
.product-detail-wrap { display:grid; grid-template-columns:1fr 1fr; gap:40px; background:#fff; border-radius:var(--radius); padding:32px; box-shadow:var(--shadow); margin-bottom:40px; }
.product-detail-img img { width:100%; height:420px; object-fit:cover; border-radius:var(--radius); }
.badge-category { background:var(--bg); color:var(--primary); padding:4px 12px; border-radius:50px; font-size:0.8rem; font-weight:600; display:inline-block; margin-bottom:12px; }
.product-detail-info h1 { font-size:1.8rem; margin-bottom:8px; }
.detail-seller { color:var(--text-light); margin-bottom:16px; }
.detail-price { font-size:2rem; font-weight:900; color:var(--primary); margin-bottom:8px; }
.detail-stock { color:var(--text-light); font-size:0.9rem; margin-bottom:16px; }
.detail-desc { color:var(--text); line-height:1.7; margin-bottom:24px; }
.order-form { margin-bottom:12px; }
.qty-wrap { display:flex; align-items:center; gap:12px; margin-bottom:16px; }
.qty-input { width:80px; padding:8px 12px; border:2px solid var(--border); border-radius:8px; font-size:1rem; text-align:center; }
.btn-order-full { width:100%; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; border:none; padding:14px; border-radius:50px; font-size:1rem; font-weight:700; cursor:pointer; transition:all 0.2s; margin-bottom:10px; }
.btn-order-full:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(108,99,255,0.35); }
.btn-chat-full { display:block; width:100%; background:transparent; border:2px solid var(--primary); color:var(--primary); padding:12px; border-radius:50px; text-align:center; text-decoration:none; font-weight:600; transition:all 0.2s; }
.btn-chat-full:hover { background:var(--primary); color:#fff; }
.login-prompt { text-align:center; padding:20px; background:var(--bg); border-radius:var(--radius); }
.login-prompt p { margin-bottom:16px; color:var(--text-light); }
.btn-primary-full { display:block; width:100%; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; border:none; padding:13px; border-radius:50px; font-size:1rem; font-weight:700; cursor:pointer; text-align:center; text-decoration:none; transition:all 0.2s; margin-bottom:10px; }
.btn-primary-full:hover { opacity:0.9; transform:translateY(-1px); }
.btn-outline-full { display:block; width:100%; border:2px solid var(--border); color:var(--text); padding:12px; border-radius:50px; text-align:center; text-decoration:none; font-weight:600; transition:all 0.2s; }

/* ===== AUTH PAGES ===== */
.auth-page { background:linear-gradient(135deg,var(--dark) 0%,var(--dark2) 50%,#0f3460 100%); min-height:100vh; display:flex; align-items:center; justify-content:center; padding:20px; }
.auth-wrapper { display:flex; gap:0; max-width:900px; width:100%; border-radius:20px; overflow:hidden; box-shadow:0 20px 60px rgba(0,0,0,0.3); }
.auth-wrapper.wide { max-width:1100px; }
.auth-brand { background:linear-gradient(135deg,var(--primary) 0%,var(--primary-dark) 50%,#2d1b69 100%); color:#fff; padding:50px 40px; flex:1; display:flex; flex-direction:column; justify-content:center; }
.logo-circle { width:64px; height:64px; background:rgba(255,255,255,0.2); border-radius:16px; display:flex; align-items:center; justify-content:center; font-size:2rem; font-weight:900; margin-bottom:16px; }
.brand-title { font-size:2.5rem; font-weight:900; margin-bottom:8px; }
.brand-sub { color:rgba(255,255,255,0.7); margin-bottom:40px; font-size:1rem; }
.brand-features { display:flex; flex-direction:column; gap:14px; }
.bf { display:flex; align-items:center; gap:12px; }
.bf i { width:36px; height:36px; background:rgba(255,255,255,0.15); border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:1rem; }
.bf span { font-size:0.95rem; }
.auth-card { background:#fff; padding:50px 40px; flex:1.2; }
.register-card { flex:1.5; overflow-y:auto; max-height:100vh; }
.auth-card h2 { font-size:1.8rem; font-weight:800; margin-bottom:6px; }
.auth-sub { color:var(--text-light); margin-bottom:28px; }
.auth-form .form-group { margin-bottom:18px; }
.auth-form label { display:block; font-size:0.85rem; font-weight:600; color:var(--text); margin-bottom:6px; }
.auth-form input, .auth-form select, .auth-form textarea { width:100%; padding:11px 14px; border:2px solid var(--border); border-radius:var(--radius-sm); font-size:0.95rem; font-family:inherit; transition:border 0.2s; }
.auth-form input:focus, .auth-form select:focus, .auth-form textarea:focus { border-color:var(--primary); outline:none; }
.auth-form textarea { resize:vertical; }
.form-row { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
.form-section-title { font-weight:700; color:var(--text); margin:20px 0 12px; font-size:0.9rem; border-bottom:2px solid var(--bg); padding-bottom:8px; }
.auth-links { margin-top:20px; text-align:center; }
.auth-links p { color:var(--text-light); font-size:0.9rem; margin-bottom:8px; }
.auth-links a { color:var(--primary); font-weight:600; text-decoration:none; }

/* Role selector */
.role-selector { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:24px; }
.role-option input { display:none; }
.role-card { border:2px solid var(--border); border-radius:var(--radius); padding:16px; text-align:center; cursor:pointer; transition:all 0.2s; }
.role-card i { display:block; font-size:2rem; margin-bottom:8px; color:var(--text-light); }
.role-card strong { display:block; font-weight:700; }
.role-card span { font-size:0.8rem; color:var(--text-light); }
.role-option input:checked + .role-card { border-color:var(--primary); background:rgba(108,99,255,0.05); }
.role-option input:checked + .role-card i { color:var(--primary); }

/* ===== ALERTS ===== */
.alert { padding:12px 16px; border-radius:var(--radius-sm); margin-bottom:16px; font-size:0.9rem; display:flex; align-items:center; gap:8px; }
.alert-danger { background:#fff0f3; color:#c0392b; border:1px solid #f5c6cb; }
.alert-success { background:#f0fff4; color:#27ae60; border:1px solid #c3e6cb; }

/* ===== FOOTER ===== */
.main-footer { background:var(--dark); color:rgba(255,255,255,0.7); padding:32px 20px; margin-top:60px; }
.footer-inner { max-width:1280px; margin:0 auto; display:flex; align-items:center; gap:24px; flex-wrap:wrap; justify-content:space-between; }
.footer-brand { display:flex; align-items:center; gap:8px; color:#fff; font-size:1.2rem; font-weight:800; }
.footer-links { display:flex; gap:16px; }
.footer-links a { color:rgba(255,255,255,0.6); text-decoration:none; font-size:0.9rem; }
.footer-links a:hover { color:#fff; }

/* ===== FORM CARD ===== */
.form-card { background:#fff; border-radius:var(--radius); padding:32px; max-width:700px; margin:0 auto; box-shadow:var(--shadow); }
.form-card h2 { margin-bottom:6px; }
.form-hint { color:var(--text-light); margin-bottom:24px; font-size:0.9rem; }
.form-group { margin-bottom:18px; }
.form-group label { display:block; font-size:0.85rem; font-weight:600; margin-bottom:6px; }
.form-group input, .form-group select, .form-group textarea { width:100%; padding:11px 14px; border:2px solid var(--border); border-radius:var(--radius-sm); font-size:0.95rem; font-family:inherit; }
.form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color:var(--primary); outline:none; }
.form-actions { display:flex; gap:12px; justify-content:flex-end; margin-top:24px; }
.btn-primary { background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; border:none; padding:11px 24px; border-radius:50px; font-weight:700; cursor:pointer; font-size:0.95rem; font-family:inherit; text-decoration:none; display:inline-flex; align-items:center; gap:8px; }
.btn-outline { border:2px solid var(--border); color:var(--text); padding:9px 22px; border-radius:50px; text-decoration:none; font-weight:600; }
.file-input { padding:8px; }
.img-preview { max-width:100%; max-height:200px; border-radius:var(--radius-sm); margin-top:8px; border:2px solid var(--border); }
.video-upload-zone { border:2px dashed var(--border); border-radius:var(--radius); padding:40px; text-align:center; cursor:pointer; color:var(--text-light); transition:all 0.2s; }
.video-upload-zone:hover { border-color:var(--primary); color:var(--primary); }
.file-selected { margin-top:8px; color:var(--text-light); font-size:0.9rem; }

/* ===== PAGE TITLES ===== */
.page-title { font-size:1.5rem; font-weight:800; margin-bottom:24px; color:var(--dark); }

/* ===== EMPTY STATES ===== */
.empty-state { text-align:center; padding:60px 20px; color:var(--text-light); }
.empty-state i { font-size:3rem; margin-bottom:16px; display:block; }

/* ===== RESPONSIVE ===== */
@media (max-width:768px) {
  .header-nav { display:none; }
  .hamburger { display:block; }
  .search-bar { max-width:200px; }
  .hero h1 { font-size:1.8rem; }
  .hero-btns { flex-direction:column; align-items:center; }
  .product-detail-wrap { grid-template-columns:1fr; }
  .auth-wrapper { flex-direction:column; max-height:none; }
  .auth-brand { padding:30px; }
  .form-row { grid-template-columns:1fr; }
  .categories-grid { grid-template-columns:repeat(auto-fill,minmax(90px,1fr)); }
}

/* ===== HDR BADGE (used for both Chat and Notification bell) ===== */
.hdr-icon-wrap {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
/* The red bubble badge */
.hdr-badge {
  position: absolute;
  top: -6px;
  right: -8px;
  min-width: 18px;
  height: 18px;
  background: #e74c3c;
  color: #fff;
  font-size: .6rem;
  font-weight: 900;
  border-radius: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
  border: 2px solid #fff;
  line-height: 1;
  pointer-events: none;
  animation: badge-pulse 1.8s ease-in-out infinite;
  z-index: 999;
  box-shadow: 0 2px 6px rgba(231,76,60,.5);
}
.hdr-badge.hidden { display: none !important; }
@keyframes badge-pulse {
  0%,100% { transform: scale(1); }
  50%      { transform: scale(1.25); }
}

/* ===== NOTIFICATION BELL ===== */
.notif-bell-wrap {
  position: relative;
  display: inline-flex;
  align-items: center;
  cursor: pointer;
}
.notif-bell-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 6px 8px;
  border-radius: 50%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background .2s, color .2s;
  color: #444;
}
.notif-bell-btn:hover { background: rgba(108,99,255,.12); color: #6c63ff; }
.notif-bell-btn .fa-bell { font-size: 1.25rem; pointer-events: none; }

/* ===== NOTIFICATION DROPDOWN ===== */
.notif-dropdown {
  display: none;
  position: absolute;
  right: -60px;
  top: calc(100% + 10px);
  width: 340px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 40px rgba(0,0,0,.18);
  border: 1px solid #f0eeff;
  z-index: 9999;
  overflow: hidden;
}
.notif-dropdown.open { display: block; }
.notif-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 18px 12px;
  border-bottom: 1px solid rgba(255,255,255,.15);
  background: linear-gradient(135deg,#6c63ff,#a855f7);
  color: #fff;
  font-weight: 700;
  font-size: .95rem;
}
.notif-header span { display:flex; align-items:center; gap:8px; }
.notif-mark-all {
  background: rgba(255,255,255,.2);
  border: 1px solid rgba(255,255,255,.4);
  color: #fff;
  font-size: .75rem;
  font-weight: 600;
  cursor: pointer;
  padding: 4px 10px;
  border-radius: 20px;
  transition: background .2s;
  white-space: nowrap;
}
.notif-mark-all:hover { background: rgba(255,255,255,.35); }
.notif-list { max-height: 380px; overflow-y: auto; }
.notif-list::-webkit-scrollbar { width: 4px; }
.notif-list::-webkit-scrollbar-thumb { background: #e0e0e0; border-radius: 4px; }
.notif-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 16px;
  text-decoration: none;
  color: #333;
  border-bottom: 1px solid #f8f4ff;
  transition: background .15s;
}
.notif-item:hover { background: #f8f4ff; }
.notif-icon {
  font-size: 1.2rem;
  min-width: 36px;
  height: 36px;
  background: #f3e8ff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.notif-body { flex: 1; min-width: 0; }
.notif-msg  { font-size: .86rem; color: #222; line-height: 1.4; font-weight: 500; }
.notif-time { font-size: .72rem; color: #aaa; margin-top: 3px; }
.notif-empty { text-align: center; padding: 36px 20px; color: #bbb; }
.notif-empty i { font-size: 2.2rem; display: block; margin-bottom: 10px; color: #d8b4fe; }
.notif-empty p { font-size: .85rem; }
.notif-footer { padding: 10px 16px; border-top: 1px solid #f0eeff; text-align: center; }
.notif-footer a {
  font-size: .82rem;
  color: #6c63ff;
  font-weight: 600;
  text-decoration: none;
.notif-footer a:hover { text-decoration: underline; }

/* ===== TOAST NOTIFICATION ===== */
.notif-toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 8px 32px rgba(0,0,0,.18);
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 18px;
  z-index: 99999;
  max-width: 320px;
  border-left: 4px solid #6c63ff;
  transform: translateX(120%);
  transition: transform .35s cubic-bezier(.34,1.56,.64,1);
}
.notif-toast.show { transform: translateX(0); }
.toast-icon { font-size: 1.5rem; flex-shrink: 0; }
.toast-body { flex: 1; }
.toast-body strong { font-size: .88rem; color: #333; display: block; }
.toast-body p { font-size: .8rem; color: #666; margin: 2px 0 0; }
.toast-close {
  background: none; border: none; cursor: pointer;
  color: #bbb; font-size: 1.1rem; padding: 0 4px; line-height: 1;
  flex-shrink: 0;
}
.toast-close:hover { color: #e74c3c; }
</style>
