<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.pw-field{position:relative}
.pw-field input{padding-right:46px}
.pw-toggle{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:#aaa;font-size:1rem;padding:4px}
.pw-toggle:hover{color:var(--primary)}
</style>
</head>
<body class="auth-page">
<div class="auth-wrapper">
  <div class="auth-brand">
    <div class="logo-circle"><span>I</span></div>
    <h1 class="brand-title">IDUKA</h1>
    <p class="brand-sub">Rwanda's Online Marketplace</p>
    <div class="brand-features">
      <div class="bf"><i class="fas fa-store"></i><span>Virtual Shops</span></div>
      <div class="bf"><i class="fas fa-mobile-alt"></i><span>Mobile Money</span></div>
      <div class="bf"><i class="fas fa-comments"></i><span>Live Chat</span></div>
      <div class="bf"><i class="fas fa-video"></i><span>Product Videos</span></div>
    </div>
  </div>
  <div class="auth-card">
    <h2>Welcome Back</h2>
    <p class="auth-sub">Sign in to your IDUKA account</p>
    <c:if test="${not empty error}">
      <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${success}</div>
    </c:if>
    <form method="post" action="<%=ctx%>/login" class="auth-form">
      <div class="form-group">
        <label><i class="fas fa-envelope"></i> Email Address</label>
        <input type="email" name="email" placeholder="your@email.com" required autofocus>
      </div>
      <div class="form-group">
        <label><i class="fas fa-lock"></i> Password</label>
        <div class="pw-field">
          <input type="password" name="password" id="loginPw" placeholder="Enter password" required>
          <button type="button" class="pw-toggle" onclick="togglePw()"><i class="fas fa-eye" id="eyeIcon"></i></button>
        </div>
      </div>
      <button type="submit" class="btn-primary-full">Login <i class="fas fa-sign-in-alt"></i></button>
    </form>
    <div class="auth-links">
      <p>Don't have an account? <a href="<%=ctx%>/register">Create Account</a></p>
      <p><a href="<%=ctx%>/home"><i class="fas fa-home"></i> Browse as Guest</a></p>
    </div>
  </div>
</div>
<script>
function togglePw() {
  var f = document.getElementById('loginPw');
  var ic = document.getElementById('eyeIcon');
  f.type = f.type === 'password' ? 'text' : 'password';
  ic.className = f.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
}
</script>
</body>
</html>
