<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile - IDUKA</title>
<jsp:include page="css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
body { background:#f4f6fb; }

/* ── Page layout ── */
.profile-page { max-width: 860px; margin: 30px auto; padding: 0 16px 60px; }

/* ── Hero card ── */
.profile-hero {
  background: linear-gradient(135deg, #6c63ff 0%, #a855f7 100%);
  border-radius: 16px;
  padding: 32px 28px;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 24px;
  margin-bottom: 24px;
  position: relative;
  overflow: hidden;
}
.profile-hero::before {
  content: '';
  position: absolute;
  width: 200px; height: 200px;
  border-radius: 50%;
  background: rgba(255,255,255,.07);
  top: -60px; right: -40px;
}

/* ── Avatar ── */
.avatar-wrap { position: relative; flex-shrink: 0; }
.avatar-circle {
  width: 90px;
  height: 90px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid rgba(255,255,255,.5);
  display: block;
  background: rgba(255,255,255,.2);
}
.avatar-initial {
  width: 90px; height: 90px;
  border-radius: 50%;
  background: rgba(255,255,255,.25);
  display: flex; align-items: center; justify-content: center;
  font-size: 2.2rem; font-weight: 700; color: #fff;
  border: 3px solid rgba(255,255,255,.5);
}
.avatar-edit-btn {
  position: absolute;
  bottom: 2px; right: 2px;
  background: #ff4d6d;
  color: #fff;
  border: 2px solid #fff;
  border-radius: 50%;
  width: 28px; height: 28px;
  font-size: .72rem;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background .2s;
}
.avatar-edit-btn:hover { background: #e03459; }

/* ── Hero info ── */
.hero-info h2 { margin: 0 0 6px; font-size: 1.4rem; font-weight: 700; }
.hero-info p  { margin: 3px 0; font-size: .88rem; opacity: .85; }
.role-badge {
  display: inline-flex; align-items: center; gap: 5px;
  background: rgba(255,255,255,.2);
  border-radius: 50px; padding: 4px 14px;
  font-size: .78rem; font-weight: 600;
  margin-top: 10px;
}

/* ── Alert banners ── */
.alert-ok  { background:#ecfdf5;color:#065f46;border:1px solid #6ee7b7;border-radius:10px;padding:12px 16px;margin-bottom:18px;font-size:.88rem }
.alert-err { background:#fef2f2;color:#991b1b;border:1px solid #fca5a5;border-radius:10px;padding:12px 16px;margin-bottom:18px;font-size:.88rem }

/* ── Tabs ── */
.profile-tabs { display: flex; gap: 4px; background: #e8e8f0; border-radius: 12px; padding: 5px; margin-bottom: 20px; }
.ptab {
  flex: 1; text-align: center; padding: 10px 8px;
  border-radius: 9px; cursor: pointer;
  font-weight: 600; font-size: .85rem;
  color: #777; border: none; background: none;
  transition: all .2s;
}
.ptab.active { background: #fff; color: #6c63ff; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
.ptab i { margin-right: 5px; }
.tab-content { display: none; }
.tab-content.active { display: block; }

/* ── Card ── */
.pcard {
  background: #fff;
  border-radius: 14px;
  padding: 26px;
  box-shadow: 0 2px 12px rgba(0,0,0,.06);
}
.pcard-title {
  display: flex; align-items: center; gap: 8px;
  font-size: 1rem; font-weight: 700; color: #333;
  margin: 0 0 20px; padding-bottom: 14px;
  border-bottom: 2px solid #f0eeff;
}
.pcard-title i { color: #6c63ff; }

/* ── Form rows ── */
.form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
@media(max-width: 540px) { .form-row-2 { grid-template-columns: 1fr; } }
.fg { margin-bottom: 16px; }
.fg label { display: block; font-size: .82rem; font-weight: 600; color: #555; margin-bottom: 5px; }
.fg input, .fg select, .fg textarea {
  width: 100%; padding: 10px 14px;
  border: 1.5px solid #e0e0e0; border-radius: 9px;
  font-size: .92rem; color: #333; background: #fff;
  transition: border .2s;
}
.fg input:focus, .fg select:focus { border-color: #6c63ff; outline: none; box-shadow: 0 0 0 3px rgba(108,99,255,.1); }
.fg input:disabled { background: #f8f8f8; color: #aaa; cursor: not-allowed; }
.fg small { font-size: .75rem; color: #999; margin-top: 3px; display: block; }
.btn-save {
  background: #6c63ff; color: #fff;
  border: none; padding: 11px 28px;
  border-radius: 10px; font-size: .92rem;
  font-weight: 600; cursor: pointer; margin-top: 4px;
}
.btn-save:hover { background: #5a52e0; }

/* ── Password helpers ── */
.pw-wrap { position: relative; }
.pw-wrap input { padding-right: 46px; }
.pw-eye { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: #aaa; font-size: .95rem; }
.pw-eye:hover { color: #6c63ff; }
.pw-bar { height: 4px; border-radius: 50px; margin-top: 5px; background: #e0e0e0; transition: all .3s; }
.pw-bar.weak   { background: #e74c3c; width: 33%; }
.pw-bar.medium { background: #f39c12; width: 66%; }
.pw-bar.strong { background: #27ae60; width: 100%; }
.pw-hint { font-size: .74rem; margin-top: 3px; min-height: 16px; }

/* ── Avatar modal ── */
.av-modal { display:none;position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:9999;align-items:center;justify-content:center }
.av-modal.open { display:flex }
.av-box { background:#fff;border-radius:16px;padding:28px;width:340px;max-width:95%;text-align:center }
.av-box h3 { margin:0 0 16px;font-size:1rem;color:#333 }
.av-preview {
  width:100px;height:100px;border-radius:50%;
  object-fit:cover;border:3px solid #e8e0ff;
  display:block;margin:0 auto 16px;
  background:#f0eeff;
}
.av-upload-zone {
  border:2px dashed #c4b5fd;border-radius:10px;padding:16px;
  cursor:pointer;color:#7c3aed;font-size:.85rem;margin-bottom:16px;
  transition:all .2s;
}
.av-upload-zone:hover { border-color:#6c63ff;background:#f5f3ff; }
.av-btns { display:flex;gap:10px }
.av-cancel { flex:1;background:#f5f5f5;color:#555;border:none;padding:10px;border-radius:8px;cursor:pointer;font-weight:600 }
.av-submit { flex:1;background:#6c63ff;color:#fff;border:none;padding:10px;border-radius:8px;cursor:pointer;font-weight:600 }
.av-submit:hover { background:#5a52e0 }
</style>
</head>
<body>
<jsp:include page="header.jsp"/>

<div class="profile-page">

  <%-- Alerts --%>
  <c:if test="${not empty param.success}">
    <div class="alert-ok"><i class="fas fa-check-circle"></i> ${param.success}</div>
  </c:if>
  <c:if test="${not empty pwError}">
    <div class="alert-err"><i class="fas fa-exclamation-circle"></i> ${pwError}</div>
  </c:if>

  <%-- Hero --%>
  <div class="profile-hero">
    <div class="avatar-wrap">
      <c:choose>
        <c:when test="${not empty profileUser.avatarUrl}">
          <img src="<%=ctx%>/uploads/${profileUser.avatarUrl}"
               class="avatar-circle" id="heroAvatar" alt="Avatar"
               onerror="this.onerror=null;this.style.display='none';document.getElementById('heroInitial').style.display='flex'">
          <div class="avatar-initial" id="heroInitial" style="display:none">
            <% com.iduka.model.User pu=(com.iduka.model.User)request.getAttribute("profileUser");
               out.print(pu!=null&&pu.getFullName()!=null&&!pu.getFullName().isEmpty() ? String.valueOf(pu.getFullName().charAt(0)).toUpperCase() : "?"); %>
          </div>
        </c:when>
        <c:otherwise>
          <div class="avatar-initial" id="heroInitial">
            <% com.iduka.model.User pu2=(com.iduka.model.User)request.getAttribute("profileUser");
               out.print(pu2!=null&&pu2.getFullName()!=null&&!pu2.getFullName().isEmpty() ? String.valueOf(pu2.getFullName().charAt(0)).toUpperCase() : "?"); %>
          </div>
        </c:otherwise>
      </c:choose>
      <button class="avatar-edit-btn" onclick="openAvatarModal()" title="Change photo">
        <i class="fas fa-camera"></i>
      </button>
    </div>
    <div class="hero-info">
      <h2>${profileUser.fullName}</h2>
      <p><i class="fas fa-envelope"></i> ${profileUser.email}</p>
      <c:if test="${not empty profileUser.phone}">
        <p><i class="fas fa-phone"></i> ${profileUser.phone}</p>
      </c:if>
      <c:if test="${not empty profileUser.village}">
        <p><i class="fas fa-map-marker-alt"></i>
          ${profileUser.village}<c:if test="${not empty profileUser.cell}">, ${profileUser.cell}</c:if><c:if test="${not empty profileUser.district}">, ${profileUser.district}</c:if>
        </p>
      </c:if>
      <span class="role-badge">
        <c:choose>
          <c:when test="${profileUser.role == 'SELLER'}"><i class="fas fa-store"></i> Seller</c:when>
          <c:otherwise><i class="fas fa-shopping-cart"></i> Buyer</c:otherwise>
        </c:choose>
      </span>
    </div>
  </div>

  <%-- Tabs --%>
  <div class="profile-tabs">
    <button class="ptab active" id="btn-info" onclick="switchTab('info',this)">
      <i class="fas fa-user"></i> Personal Info
    </button>
    <button class="ptab" id="btn-address" onclick="switchTab('address',this)">
      <i class="fas fa-map-marker-alt"></i> Address
    </button>
    <button class="ptab" id="btn-password" onclick="switchTab('password',this)">
      <i class="fas fa-lock"></i> Password
    </button>
  </div>

  <%-- Tab: Personal Info --%>
  <div class="tab-content active" id="content-info">
    <div class="pcard">
      <div class="pcard-title"><i class="fas fa-user"></i> Personal Information</div>
      <form method="post" action="<%=ctx%>/profile">
        <input type="hidden" name="action"   value="updateProfile">
        <input type="hidden" name="country"  value="${profileUser.country}">
        <input type="hidden" name="province" value="${profileUser.province}">
        <input type="hidden" name="district" value="${profileUser.district}">
        <input type="hidden" name="sector"   value="${profileUser.sector}">
        <input type="hidden" name="cell"     value="${profileUser.cell}">
        <input type="hidden" name="village"  value="${profileUser.village}">
        <div class="form-row-2">
          <div class="fg">
            <label><i class="fas fa-user"></i> Full Name</label>
            <input type="text" name="fullName" value="${profileUser.fullName}" required>
          </div>
          <div class="fg">
            <label><i class="fas fa-phone"></i> Phone Number</label>
            <input type="text" name="phone" value="${profileUser.phone}">
          </div>
        </div>
        <div class="fg">
          <label><i class="fas fa-envelope"></i> Email Address</label>
          <input type="email" value="${profileUser.email}" disabled>
          <small><i class="fas fa-info-circle"></i> Email cannot be changed</small>
        </div>
        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save Changes</button>
      </form>
    </div>
  </div>

  <%-- Tab: Address --%>
  <div class="tab-content" id="content-address">
    <div class="pcard">
      <div class="pcard-title"><i class="fas fa-map-marker-alt"></i> Your Address</div>
      <form method="post" action="<%=ctx%>/profile">
        <input type="hidden" name="action"   value="updateProfile">
        <input type="hidden" name="fullName" value="${profileUser.fullName}">
        <input type="hidden" name="phone"    value="${profileUser.phone}">
        <div class="form-row-2">
          <div class="fg">
            <label>Country</label>
            <select name="country">
              <option value="Rwanda"   ${profileUser.country=='Rwanda'   ?'selected':''}>Rwanda</option>
              <option value="Uganda"   ${profileUser.country=='Uganda'   ?'selected':''}>Uganda</option>
              <option value="Kenya"    ${profileUser.country=='Kenya'    ?'selected':''}>Kenya</option>
              <option value="Tanzania" ${profileUser.country=='Tanzania' ?'selected':''}>Tanzania</option>
              <option value="DRC"      ${profileUser.country=='DRC'      ?'selected':''}>DRC</option>
              <option value="Burundi"  ${profileUser.country=='Burundi'  ?'selected':''}>Burundi</option>
            </select>
          </div>
          <div class="fg">
            <label>Province</label>
            <select name="province">
              <option value="Kigali City"      ${profileUser.province=='Kigali City'      ?'selected':''}>Kigali City</option>
              <option value="Eastern Province" ${profileUser.province=='Eastern Province' ?'selected':''}>Eastern Province</option>
              <option value="Western Province" ${profileUser.province=='Western Province' ?'selected':''}>Western Province</option>
              <option value="Northern Province"${profileUser.province=='Northern Province'?'selected':''}>Northern Province</option>
              <option value="Southern Province"${profileUser.province=='Southern Province'?'selected':''}>Southern Province</option>
            </select>
          </div>
        </div>
        <div class="form-row-2">
          <div class="fg">
            <label>District</label>
            <input type="text" name="district" value="${profileUser.district}" placeholder="e.g. Nyagatare">
          </div>
          <div class="fg">
            <label>Sector</label>
            <input type="text" name="sector" value="${profileUser.sector}" placeholder="e.g. Karangazi">
          </div>
        </div>
        <div class="form-row-2">
          <div class="fg">
            <label>Cell</label>
            <input type="text" name="cell" value="${profileUser.cell}" placeholder="e.g. Rwisirabo">
          </div>
          <div class="fg">
            <label>Village</label>
            <input type="text" name="village" value="${profileUser.village}" placeholder="e.g. Rubona">
          </div>
        </div>
        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save Address</button>
      </form>
    </div>
  </div>

  <%-- Tab: Password --%>
  <div class="tab-content" id="content-password">
    <div class="pcard">
      <div class="pcard-title"><i class="fas fa-lock"></i> Change Password</div>
      <form method="post" action="<%=ctx%>/profile" id="pwForm">
        <input type="hidden" name="action" value="changePassword">
        <div class="fg">
          <label>Current Password</label>
          <div class="pw-wrap">
            <input type="password" name="oldPassword" id="oldPw" placeholder="Enter current password" required>
            <button type="button" class="pw-eye" onclick="togglePw('oldPw',this)"><i class="fas fa-eye"></i></button>
          </div>
        </div>
        <div class="fg">
          <label>New Password</label>
          <div class="pw-wrap">
            <input type="password" name="newPassword" id="newPw" placeholder="Min. 6 characters" minlength="6" required oninput="checkStrength(this.value)">
            <button type="button" class="pw-eye" onclick="togglePw('newPw',this)"><i class="fas fa-eye"></i></button>
          </div>
          <div class="pw-bar" id="pwBar"></div>
          <div class="pw-hint" id="pwHint"></div>
        </div>
        <div class="fg">
          <label>Confirm New Password</label>
          <div class="pw-wrap">
            <input type="password" name="confirmPassword" id="confPw" placeholder="Re-enter new password" required oninput="checkMatch()">
            <button type="button" class="pw-eye" onclick="togglePw('confPw',this)"><i class="fas fa-eye"></i></button>
          </div>
          <div class="pw-hint" id="matchMsg"></div>
        </div>
        <button type="submit" class="btn-save"><i class="fas fa-key"></i> Change Password</button>
      </form>
    </div>
  </div>

</div>

<%-- Avatar Upload Modal --%>
<div class="av-modal" id="avatarModal">
  <div class="av-box">
    <h3><i class="fas fa-camera" style="color:#6c63ff"></i> Update Profile Photo</h3>
    <img id="avPreview"
         src="<c:choose><c:when test='${not empty profileUser.avatarUrl}'><%=ctx%>/uploads/${profileUser.avatarUrl}</c:when><c:otherwise><%=ctx%>/images/default-product.svg</c:otherwise></c:choose>"
         class="av-preview" alt="Preview"
         onerror="this.src='<%=ctx%>/images/default-product.svg'">
    <form method="post" action="<%=ctx%>/profile" enctype="multipart/form-data">
      <input type="hidden" name="action" value="uploadAvatar">
      <div class="av-upload-zone" onclick="document.getElementById('avInput').click()">
        <i class="fas fa-cloud-upload-alt fa-lg"></i>
        <span id="avLabel" style="display:block;margin-top:6px">Click to choose a photo (JPG, PNG)</span>
      </div>
      <input type="file" name="avatar" id="avInput" accept="image/*" style="display:none" onchange="previewAv(this)">
      <div class="av-btns">
        <button type="button" class="av-cancel" onclick="closeAvatarModal()">Cancel</button>
        <button type="submit" class="av-submit"><i class="fas fa-save"></i> Save Photo</button>
      </div>
    </form>
  </div>
</div>

<script src="<%=ctx%>/js/main.js"></script>
<script>
// ── Tabs ─────────────────────────────────────────────────────────────
function switchTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(function(t){ t.classList.remove('active'); });
  document.querySelectorAll('.ptab').forEach(function(b){ b.classList.remove('active'); });
  document.getElementById('content-' + name).classList.add('active');
  if (btn) btn.classList.add('active');
}
<c:if test="${activeTab == 'password'}">
switchTab('password', document.getElementById('btn-password'));
</c:if>

// ── Password ─────────────────────────────────────────────────────────
function togglePw(id, btn) {
  var f = document.getElementById(id);
  var i = btn.querySelector('i');
  f.type = f.type === 'password' ? 'text' : 'password';
  i.className = f.type === 'password' ? 'fas fa-eye' : 'fas fa-eye-slash';
}
function checkStrength(val) {
  var bar  = document.getElementById('pwBar');
  var hint = document.getElementById('pwHint');
  bar.className = 'pw-bar';
  if (!val) { hint.innerHTML = ''; return; }
  var s = 0;
  if (val.length >= 8) s++;
  if (/[A-Z]/.test(val)) s++;
  if (/[0-9]/.test(val)) s++;
  if (/[^A-Za-z0-9]/.test(val)) s++;
  if (s <= 1) { bar.classList.add('weak');   hint.innerHTML='<span style="color:#e74c3c">🔴 Weak</span>'; }
  else if(s<=2){bar.classList.add('medium'); hint.innerHTML='<span style="color:#f39c12">🟡 Medium</span>';}
  else         { bar.classList.add('strong'); hint.innerHTML='<span style="color:#27ae60">🟢 Strong</span>'; }
  checkMatch();
}
function checkMatch() {
  var n = document.getElementById('newPw').value;
  var c = document.getElementById('confPw').value;
  var m = document.getElementById('matchMsg');
  if (!c) { m.innerHTML = ''; return; }
  m.innerHTML = n === c
    ? '<span style="color:#27ae60"><i class="fas fa-check"></i> Passwords match</span>'
    : '<span style="color:#e74c3c"><i class="fas fa-times"></i> Passwords do not match</span>';
}
document.getElementById('pwForm').addEventListener('submit', function(e) {
  if (document.getElementById('newPw').value !== document.getElementById('confPw').value) {
    e.preventDefault();
    document.getElementById('matchMsg').innerHTML = '<span style="color:#e74c3c">Passwords do not match!</span>';
  }
});

// ── Avatar modal ─────────────────────────────────────────────────────
function openAvatarModal() {
  document.getElementById('avatarModal').classList.add('open');
}
function closeAvatarModal() {
  document.getElementById('avatarModal').classList.remove('open');
}
function previewAv(input) {
  if (!input.files[0]) return;
  var reader = new FileReader();
  reader.onload = function(e) {
    document.getElementById('avPreview').src = e.target.result;
    document.getElementById('avLabel').textContent = '✓ ' + input.files[0].name;
  };
  reader.readAsDataURL(input.files[0]);
}
// Close modal on backdrop click
document.getElementById('avatarModal').addEventListener('click', function(e) {
  if (e.target === this) closeAvatarModal();
});
</script>
</body>
</html>
