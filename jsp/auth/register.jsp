<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Register - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* ─── Wide auth layout for register ──────────────────────── */
.auth-wrapper.wide { max-width: 1000px; }
.register-card     { max-width: 620px; }

/* ─── Role selector ─────────────────────────────────────── */
.role-selector { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:20px; }
.role-option input[type=radio] { display:none; }
.role-card {
  border: 2px solid #e0e0e0; border-radius:12px; padding:16px 12px;
  text-align:center; cursor:pointer; transition:all .2s;
}
.role-card i       { font-size:1.8rem; color:#aaa; display:block; margin-bottom:8px; }
.role-card strong  { display:block; font-size:.95rem; color:#333; }
.role-card span    { font-size:.78rem; color:#999; }
.role-option input:checked + .role-card {
  border-color: #6c63ff; background:#f5f3ff;
}
.role-option input:checked + .role-card i { color:#6c63ff; }
.role-option input:checked + .role-card strong { color:#6c63ff; }

/* ─── Form sections ─────────────────────────────────────── */
.form-section-title {
  font-size:.8rem; font-weight:700; text-transform:uppercase;
  letter-spacing:.08em; color:#6c63ff; margin:20px 0 10px;
  display:flex; align-items:center; gap:8px;
}
.form-section-title::after {
  content:''; flex:1; height:1px; background:#e8e0ff;
}
.form-row { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
@media(max-width:520px){ .form-row{ grid-template-columns:1fr; } }

/* ─── Password ──────────────────────────────────────────── */
.pw-field { position:relative; }
.pw-field input { padding-right:46px; }
.pw-toggle {
  position:absolute; right:12px; top:50%; transform:translateY(-50%);
  background:none; border:none; cursor:pointer; color:#aaa; font-size:1rem; padding:4px;
}
.pw-toggle:hover { color:var(--primary); }
.pw-strength { height:4px; border-radius:50px; margin-top:5px; background:#e0e0e0; transition:all .3s; width:0; }
.pw-strength.weak   { background:#e74c3c; width:33%; }
.pw-strength.medium { background:#f39c12; width:66%; }
.pw-strength.strong { background:#27ae60; width:100%; }
.pw-hint   { font-size:.74rem; margin-top:3px; min-height:16px; }
#matchMsg  { font-size:.74rem; margin-top:4px; min-height:16px; }

/* ─── Seller verification box ───────────────────────────── */
.seller-section {
  display:none; background:#f8f0ff;
  border:2px dashed #c4b5fd; border-radius:14px;
  padding:20px; margin:4px 0 12px;
}
.seller-section.visible { display:block; }
.seller-section h4 {
  margin:0 0 6px; color:#6c63ff; font-size:.95rem;
  display:flex; align-items:center; gap:8px;
}
.seller-note {
  background:#ede9fe; border-radius:8px; padding:10px 12px;
  font-size:.82rem; color:#5b21b6; margin-bottom:14px;
  display:flex; gap:8px; align-items:flex-start; line-height:1.5;
}

/* ─── ID card upload ────────────────────────────────────── */
.id-upload-zone {
  border:2px dashed #c4b5fd; border-radius:10px;
  padding:18px; text-align:center; cursor:pointer;
  background:#fff; transition:all .2s; margin-top:4px;
}
.id-upload-zone:hover { border-color:#6c63ff; background:#f5f3ff; }
.id-upload-zone i   { font-size:2rem; color:#a78bfa; display:block; margin-bottom:6px; }
.id-upload-zone span { font-size:.85rem; color:#7c3aed; }
.id-preview {
  width:100%; max-height:160px; object-fit:cover;
  border-radius:8px; margin-top:10px; display:none;
  border:2px solid #c4b5fd;
}

/* ─── Address selects ───────────────────────────────────── */
.addr-select {
  width:100%; padding:10px 14px; border:1px solid var(--border,#e0e0e0);
  border-radius:8px; font-size:.92rem; background:#fff; color:var(--dark,#333);
  outline:none; transition:border .2s;
}
.addr-select:focus   { border-color:#6c63ff; box-shadow:0 0 0 3px rgba(108,99,255,.1); }
.addr-select:disabled { background:#f8f8f8; color:#bbb; cursor:not-allowed; }
</style>
</head>
<body class="auth-page">
<div class="auth-wrapper wide">

  <%-- Left brand panel --%>
  <div class="auth-brand">
    <div class="logo-circle"><span>I</span></div>
    <h1 class="brand-title">IDUKA</h1>
    <p class="brand-sub">Rwanda's Digital Marketplace</p>
    <div class="brand-features">
      <div class="bf"><i class="fas fa-store"></i><span>Sell Nationwide</span></div>
      <div class="bf"><i class="fas fa-shield-alt"></i><span>Verified Sellers</span></div>
      <div class="bf"><i class="fas fa-bell"></i><span>Live Notifications</span></div>
      <div class="bf"><i class="fas fa-mobile-alt"></i><span>Mobile Money</span></div>
    </div>
  </div>

  <%-- Right form card --%>
  <div class="auth-card register-card">
    <h2><i class="fas fa-user-plus" style="color:#6c63ff"></i> Create Account</h2>
    <p class="auth-sub">Join thousands of buyers &amp; sellers across Rwanda</p>

    <c:if test="${not empty error}">
      <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${error}</div>
    </c:if>
    <c:if test="${not empty param.success}">
      <div class="alert alert-success"><i class="fas fa-check-circle"></i> ${param.success}</div>
    </c:if>

    <form method="post" action="<%=ctx%>/register" enctype="multipart/form-data" id="regForm">

      <%-- ① Role --%>
      <div class="form-section-title">I want to</div>
      <div class="role-selector">
        <label class="role-option">
          <input type="radio" name="role" value="BUYER" id="roleBuyer" onchange="switchRole('BUYER')" ${selectedRole == 'BUYER' ? 'checked' : ''} required>
          <div class="role-card">
            <i class="fas fa-shopping-cart"></i>
            <strong>Buy Products</strong>
            <span>Browse &amp; order from sellers</span>
          </div>
        </label>
        <label class="role-option">
          <input type="radio" name="role" value="SELLER" id="roleSeller" onchange="switchRole('SELLER')" ${selectedRole == 'SELLER' ? 'checked' : ''}>
          <div class="role-card">
            <i class="fas fa-store"></i>
            <strong>Sell Products</strong>
            <span>Open my shop online</span>
          </div>
        </label>
      </div>

      <%-- ② Personal info --%>
      <div class="form-section-title"><i class="fas fa-user"></i> Personal Information</div>
      <div class="form-row">
        <div class="form-group">
          <label>Full Name *</label>
          <input type="text" name="fullName" placeholder="Jean Baptiste Kagame" required>
        </div>
        <div class="form-group">
          <label>Phone Number *</label>
          <input type="text" name="phone" placeholder="+250780000000" required>
        </div>
      </div>
      <div class="form-group">
        <label>Email Address *</label>
        <input type="email" name="email" placeholder="your@email.com" required>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Password *</label>
          <div class="pw-field">
            <input type="password" name="password" id="regPw" placeholder="Min. 6 characters"
                   minlength="6" required oninput="checkStrength(this.value)">
            <button type="button" class="pw-toggle" onclick="togglePw('regPw',this)">
              <i class="fas fa-eye"></i>
            </button>
          </div>
          <div class="pw-strength" id="strengthBar"></div>
          <div class="pw-hint"    id="strengthLabel"></div>
        </div>
        <div class="form-group">
          <label>Confirm Password *</label>
          <div class="pw-field">
            <input type="password" name="confirmPassword" id="confPw"
                   placeholder="Re-enter password" required oninput="checkMatch()">
            <button type="button" class="pw-toggle" onclick="togglePw('confPw',this)">
              <i class="fas fa-eye"></i>
            </button>
          </div>
          <div id="matchMsg"></div>
        </div>
      </div>

      <%-- ③ Seller Verification (hidden until SELLER role selected) --%>
      <div class="seller-section" id="sellerSection">
        <h4><i class="fas fa-shield-alt"></i> Seller Verification — Required</h4>
        <div class="seller-note">
          <i class="fas fa-info-circle" style="margin-top:2px;flex-shrink:0"></i>
          To protect buyers from scams, all sellers must verify their identity with a National ID and TIN number.
          Your details are securely stored and never shared publicly.
        </div>
        <div class="form-row">
          <div class="form-group">
            <label><i class="fas fa-id-card"></i> National ID Number *</label>
            <input type="text" name="idNumber" id="idNumberInput"
                   placeholder="e.g. 1200780000000" maxlength="16" pattern="[0-9]{16}">
            <small style="color:#888;font-size:.75rem">16-digit Rwandan national ID</small>
          </div>
          <div class="form-group">
            <label><i class="fas fa-building"></i> TIN Number *</label>
            <input type="text" name="tinNumber" id="tinNumberInput"
                   placeholder="e.g. 123456789" maxlength="12">
            <small style="color:#888;font-size:.75rem">Rwanda Revenue Authority TIN</small>
          </div>
        </div>
        <div class="form-group">
          <label><i class="fas fa-camera"></i> National ID Card Photo *</label>
          <div class="id-upload-zone" onclick="document.getElementById('idCardInput').click()">
            <i class="fas fa-cloud-upload-alt"></i>
            <span id="idCardLabel">Click to upload front of your ID card (JPG, PNG, max 5MB)</span>
          </div>
          <input type="file" name="idCard" id="idCardInput" accept="image/*"
                 style="display:none" onchange="previewIdCard(this)">
          <img id="idCardPreview" class="id-preview" alt="ID Card Preview">
        </div>
      </div>

      <%-- ④ Address --%>
      <div class="form-section-title"><i class="fas fa-map-marker-alt"></i> Your Address</div>
      <div class="form-row">
        <div class="form-group">
          <label>Country</label>
          <input type="text" name="country" value="Rwanda" placeholder="Country">
        </div>
        <div class="form-group">
          <label>Province</label>
          <input type="text" name="province" placeholder="e.g. Eastern Province">
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>District</label>
          <input type="text" name="district" placeholder="e.g. Nyagatare">
        </div>
        <div class="form-group">
          <label>Sector</label>
          <input type="text" name="sector" placeholder="e.g. Karangazi">
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Cell</label>
          <input type="text" name="cell" placeholder="e.g. Rwisirabo">
        </div>
        <div class="form-group">
          <label>Village</label>
          <input type="text" name="village" placeholder="e.g. Rubona">
        </div>
      </div>

      <button type="submit" class="btn-primary-full" id="regBtn" style="margin-top:20px">
        <i class="fas fa-user-plus"></i> Create My Account
      </button>
    </form>

    <div class="auth-links">
      <p>Already have an account? <a href="<%=ctx%>/login">Login here</a></p>
    </div>
  </div>
</div>

<script>
// Initialize role selection if pre-selected
document.addEventListener('DOMContentLoaded', function() {
  var buyerRadio = document.getElementById('roleBuyer');
  var sellerRadio = document.getElementById('roleSeller');
  if (buyerRadio && buyerRadio.checked) {
    switchRole('BUYER');
  } else if (sellerRadio && sellerRadio.checked) {
    switchRole('SELLER');
  }
});

// ── Role toggle ───────────────────────────────────────────────────────
function switchRole(role) {
  var s    = document.getElementById('sellerSection');
  var idIn = document.getElementById('idNumberInput');
  var tnIn = document.getElementById('tinNumberInput');
  if (role === 'SELLER') {
    s.classList.add('visible');
    idIn.required = true; tnIn.required = true;
  } else {
    s.classList.remove('visible');
    idIn.required = false; tnIn.required = false;
  }
}



// ── Password ──────────────────────────────────────────────────────────
function togglePw(id, btn) {
  var f = document.getElementById(id);
  var ic = btn.querySelector('i');
  f.type = (f.type === 'password') ? 'text' : 'password';
  ic.className = (f.type === 'password') ? 'fas fa-eye' : 'fas fa-eye-slash';
}
function checkStrength(val) {
  var bar = document.getElementById('strengthBar');
  var lbl = document.getElementById('strengthLabel');
  bar.className = 'pw-strength';
  if (!val) { lbl.innerHTML = ''; return; }
  var s = 0;
  if (val.length >= 8) s++;
  if (/[A-Z]/.test(val)) s++;
  if (/[0-9]/.test(val)) s++;
  if (/[^A-Za-z0-9]/.test(val)) s++;
  if (s <= 1) {
    bar.classList.add('weak');
    lbl.innerHTML = '<span style="color:#e74c3c">🔴 Weak — add uppercase, numbers or symbols</span>';
  } else if (s <= 2) {
    bar.classList.add('medium');
    lbl.innerHTML = '<span style="color:#f39c12">🟡 Medium — getting better</span>';
  } else {
    bar.classList.add('strong');
    lbl.innerHTML = '<span style="color:#27ae60">🟢 Strong password!</span>';
  }
  checkMatch();
}
function checkMatch() {
  var n = document.getElementById('regPw').value;
  var c = document.getElementById('confPw').value;
  var m = document.getElementById('matchMsg');
  if (!c) { m.innerHTML = ''; return; }
  m.innerHTML = (n === c)
    ? '<span style="color:#27ae60"><i class="fas fa-check"></i> Passwords match ✓</span>'
    : '<span style="color:#e74c3c"><i class="fas fa-times"></i> Passwords do not match</span>';
}

// ── ID card preview ──────────────────────────────────────────────────
function previewIdCard(input) {
  if (!input.files[0]) return;
  var reader = new FileReader();
  reader.onload = function(e) {
    var img = document.getElementById('idCardPreview');
    img.src = e.target.result;
    img.style.display = 'block';
    document.getElementById('idCardLabel').textContent = '✓ ' + input.files[0].name;
  };
  reader.readAsDataURL(input.files[0]);
}

// ── Submit guard ─────────────────────────────────────────────────────
document.getElementById('regForm').addEventListener('submit', function(e) {
  var n = document.getElementById('regPw').value;
  var c = document.getElementById('confPw').value;
  if (n !== c) {
    e.preventDefault();
    document.getElementById('matchMsg').innerHTML =
      '<span style="color:#e74c3c"><i class="fas fa-times"></i> Passwords do not match!</span>';
    document.getElementById('confPw').focus();
    return;
  }
  document.getElementById('regBtn').innerHTML =
    '<i class="fas fa-spinner fa-spin"></i> Creating account…';
  document.getElementById('regBtn').disabled = true;
});
</script>
</body>
</html>
