/**
 * IDUKA — Comprehensive Form Validation
 * Covers: Login, Register, Add Product, Edit Product, Order, Chat, Profile, Upload Video
 */

// ── Utility helpers ────────────────────────────────────────────────────────
function showError(input, msg) {
  clearError(input);
  input.classList.add('input-error');
  var err = document.createElement('div');
  err.className = 'field-error';
  err.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + msg;
  input.parentNode.insertBefore(err, input.nextSibling);
  input.focus();
}
function clearError(input) {
  input.classList.remove('input-error');
  input.classList.remove('input-ok');
  var next = input.nextSibling;
  if (next && next.className === 'field-error') next.remove();
}
function showOk(input) {
  clearError(input);
  input.classList.add('input-ok');
}
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
}
function isValidPhone(phone) {
  var p = phone.replace(/\s+/g, '');
  return /^(07[2-9]\d{7}|250\d{9}|\+250\d{9})$/.test(p);
}
function isValidRwandaPhone(phone) {
  var p = phone.replace(/[\s\-]/g, '');
  return /^(07[2-9]\d{7}|250[7][2-9]\d{7}|\+250[7][2-9]\d{7})$/.test(p);
}

// ── Real-time field validation ────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {

  // Attach blur validation to all required inputs
  document.querySelectorAll('input[required], select[required], textarea[required]').forEach(function (el) {
    el.addEventListener('blur', function () { validateField(el); });
    el.addEventListener('input', function () {
      if (el.classList.contains('input-error')) validateField(el);
    });
  });

  // ── LOGIN FORM ────────────────────────────────────────────────────────
  var loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', function (e) {
      var email = loginForm.querySelector('[name="email"]');
      var pass  = loginForm.querySelector('[name="password"]');
      var ok = true;
      if (!email.value.trim()) { showError(email, 'Email is required'); ok = false; }
      else if (!isValidEmail(email.value)) { showError(email, 'Enter a valid email address'); ok = false; }
      if (!pass.value) { showError(pass, 'Password is required'); ok = false; }
      if (!ok) e.preventDefault();
    });
  }

  // ── REGISTER FORM ─────────────────────────────────────────────────────
  var regForm = document.getElementById('registerForm');
  if (regForm) {
    regForm.addEventListener('submit', function (e) {
      var ok = true;
      var fullName = regForm.querySelector('[name="fullName"]');
      var email    = regForm.querySelector('[name="email"]');
      var phone    = regForm.querySelector('[name="phone"]');
      var pass     = regForm.querySelector('[name="password"]');
      var confirm  = regForm.querySelector('[name="confirmPassword"]');
      var role     = regForm.querySelector('[name="role"]:checked');

      if (!fullName.value.trim()) { showError(fullName, 'Full name is required'); ok = false; }
      else if (fullName.value.trim().length < 3) { showError(fullName, 'Name must be at least 3 characters'); ok = false; }

      if (!email.value.trim()) { showError(email, 'Email is required'); ok = false; }
      else if (!isValidEmail(email.value)) { showError(email, 'Enter a valid email address (e.g. name@gmail.com)'); ok = false; }

      if (phone && phone.value.trim() && !isValidPhone(phone.value)) {
        showError(phone, 'Enter a valid Rwanda phone number (e.g. 0781234567)'); ok = false;
      }

      if (!pass.value) { showError(pass, 'Password is required'); ok = false; }
      else if (pass.value.length < 6) { showError(pass, 'Password must be at least 6 characters'); ok = false; }
      else if (!/[A-Za-z]/.test(pass.value) || !/[0-9]/.test(pass.value)) {
        showError(pass, 'Password must contain letters and numbers'); ok = false;
      }

      if (confirm && pass.value !== confirm.value) {
        showError(confirm, 'Passwords do not match'); ok = false;
      }

      if (!role) {
        var roleErr = document.getElementById('roleError');
        if (!roleErr) {
          roleErr = document.createElement('div');
          roleErr.id = 'roleError';
          roleErr.className = 'field-error';
          roleErr.innerHTML = '<i class="fas fa-exclamation-circle"></i> Please select Buyer or Seller';
          var roleSection = document.querySelector('.role-selector');
          if (roleSection) roleSection.after(roleErr);
        }
        ok = false;
      } else {
        var roleErr = document.getElementById('roleError');
        if (roleErr) roleErr.remove();
      }

      // Seller fields
      if (role && role.value === 'SELLER') {
        var idNum = regForm.querySelector('[name="idNumber"]');
        var tin   = regForm.querySelector('[name="tinNumber"]');
        if (idNum && !idNum.value.trim()) { showError(idNum, 'National ID number is required for sellers'); ok = false; }
        else if (idNum && idNum.value.trim().length < 8) { showError(idNum, 'Enter a valid National ID number'); ok = false; }
        if (tin && !tin.value.trim()) { showError(tin, 'TIN number is required for sellers'); ok = false; }
      }

      if (!ok) e.preventDefault();
    });
  }

  // ── ADD / EDIT PRODUCT FORM ───────────────────────────────────────────
  var productForm = document.getElementById('productForm') || document.getElementById('editProductForm');
  if (productForm) {
    productForm.addEventListener('submit', function (e) {
      var ok = true;
      var name  = productForm.querySelector('[name="name"]');
      var price = productForm.querySelector('[name="price"]');
      var stock = productForm.querySelector('[name="stock"]');
      var cat   = productForm.querySelector('[name="categoryId"]');

      if (!name.value.trim()) { showError(name, 'Product name is required'); ok = false; }
      else if (name.value.trim().length < 2) { showError(name, 'Product name must be at least 2 characters'); ok = false; }

      if (!price.value) { showError(price, 'Price is required'); ok = false; }
      else if (parseFloat(price.value) <= 0) { showError(price, 'Price must be greater than 0'); ok = false; }
      else if (parseFloat(price.value) > 100000000) { showError(price, 'Price seems too high — please check'); ok = false; }

      if (!stock.value && stock.value !== '0') { showError(stock, 'Stock quantity is required'); ok = false; }
      else if (parseInt(stock.value) < 0) { showError(stock, 'Stock cannot be negative'); ok = false; }

      if (cat && !cat.value) { showError(cat, 'Please select a category'); ok = false; }

      if (!ok) e.preventDefault();
    });
  }

  // ── ORDER / BUY FORM ──────────────────────────────────────────────────
  var orderForm = document.getElementById('orderForm');
  if (orderForm) {
    orderForm.addEventListener('submit', function (e) {
      var ok = true;
      var qty     = orderForm.querySelector('[name="quantity"]');
      var method  = orderForm.querySelector('[name="paymentMethod"]:checked');
      var mtn     = orderForm.querySelector('[name="mtnNumber"]');
      var airtel  = orderForm.querySelector('[name="airtelNumber"]');

      if (!qty || parseInt(qty.value) < 1) { showError(qty, 'Quantity must be at least 1'); ok = false; }

      if (!method) {
        var pmErr = document.getElementById('pmError');
        if (!pmErr) {
          pmErr = document.createElement('div');
          pmErr.id = 'pmError';
          pmErr.className = 'field-error';
          pmErr.innerHTML = '<i class="fas fa-exclamation-circle"></i> Please select a payment method';
          var paySection = document.querySelector('.payment-section');
          if (paySection) paySection.appendChild(pmErr);
        }
        ok = false;
      } else {
        var pmErr = document.getElementById('pmError');
        if (pmErr) pmErr.remove();

        // Validate phone for mobile money
        if (method.value === 'MTN MoMo' && mtn && mtn.value.trim()) {
          if (!isValidRwandaPhone(mtn.value)) {
            showError(mtn, 'Enter a valid MTN number (e.g. 0781234567)'); ok = false;
          }
        }
        if (method.value === 'Airtel Money' && airtel && airtel.value.trim()) {
          if (!isValidRwandaPhone(airtel.value)) {
            showError(airtel, 'Enter a valid Airtel number (e.g. 0721234567)'); ok = false;
          }
        }
      }

      if (!ok) e.preventDefault();
    });
  }

  // ── CHAT MESSAGE ──────────────────────────────────────────────────────
  var chatInput = document.querySelector('.chat-input-wrap input[name="message"]');
  if (chatInput) {
    chatInput.closest('form').addEventListener('submit', function (e) {
      if (!chatInput.value.trim()) {
        e.preventDefault();
        chatInput.placeholder = '⚠️ Please type a message first';
        chatInput.classList.add('input-error');
        setTimeout(function () {
          chatInput.placeholder = 'Type your message...';
          chatInput.classList.remove('input-error');
        }, 2000);
      }
    });
  }

  // ── UPLOAD VIDEO FORM ─────────────────────────────────────────────────
  var videoForm = document.getElementById('videoForm');
  if (videoForm) {
    videoForm.addEventListener('submit', function (e) {
      var ok = true;
      var title   = videoForm.querySelector('[name="title"]');
      var product = videoForm.querySelector('[name="productId"]');
      var file    = videoForm.querySelector('[name="video"]');

      if (title && !title.value.trim()) { showError(title, 'Video title is required'); ok = false; }
      if (product && !product.value) { showError(product, 'Please select a product for this video'); ok = false; }
      if (file && !file.files.length) {
        var fileErr = document.getElementById('fileError');
        if (!fileErr) {
          fileErr = document.createElement('div');
          fileErr.id = 'fileError';
          fileErr.className = 'field-error';
          fileErr.innerHTML = '<i class="fas fa-exclamation-circle"></i> Please select a video file';
          file.parentNode.appendChild(fileErr);
        }
        ok = false;
      }
      if (!ok) e.preventDefault();
    });
  }

  // ── PROFILE FORM ──────────────────────────────────────────────────────
  var profileForm = document.getElementById('profileForm');
  if (profileForm) {
    profileForm.addEventListener('submit', function (e) {
      var ok = true;
      var fullName = profileForm.querySelector('[name="fullName"]');
      var phone    = profileForm.querySelector('[name="phone"]');

      if (!fullName.value.trim()) { showError(fullName, 'Full name is required'); ok = false; }
      else if (fullName.value.trim().length < 3) { showError(fullName, 'Name must be at least 3 characters'); ok = false; }

      if (phone && phone.value.trim() && !isValidPhone(phone.value)) {
        showError(phone, 'Enter a valid Rwanda phone number (e.g. 0781234567)'); ok = false;
      }
      if (!ok) e.preventDefault();
    });
  }

  // ── PASSWORD CHANGE FORM ──────────────────────────────────────────────
  var pwForm = document.getElementById('passwordForm');
  if (pwForm) {
    pwForm.addEventListener('submit', function (e) {
      var ok = true;
      var oldPw  = pwForm.querySelector('[name="oldPassword"]');
      var newPw  = pwForm.querySelector('[name="newPassword"]');
      var confPw = pwForm.querySelector('[name="confirmPassword"]');

      if (!oldPw.value) { showError(oldPw, 'Current password is required'); ok = false; }
      if (!newPw.value) { showError(newPw, 'New password is required'); ok = false; }
      else if (newPw.value.length < 6) { showError(newPw, 'Password must be at least 6 characters'); ok = false; }
      if (newPw.value && confPw.value !== newPw.value) { showError(confPw, 'Passwords do not match'); ok = false; }
      if (!ok) e.preventDefault();
    });
  }
});

// ── Per-field validation ───────────────────────────────────────────────────
function validateField(el) {
  var val = el.value.trim();
  var name = el.getAttribute('name');

  if (el.required && !val) {
    var label = el.closest('.form-group') &&
                el.closest('.form-group').querySelector('label');
    showError(el, (label ? label.textContent.replace('*','').trim() : 'This field') + ' is required');
    return false;
  }

  if (name === 'email' && val && !isValidEmail(val)) {
    showError(el, 'Enter a valid email address'); return false;
  }
  if (name === 'phone' && val && !isValidPhone(val)) {
    showError(el, 'Enter a valid Rwanda phone number (e.g. 0781234567)'); return false;
  }
  if ((name === 'mtnNumber' || name === 'airtelNumber') && val && !isValidRwandaPhone(val)) {
    showError(el, 'Enter a valid Rwanda mobile number'); return false;
  }
  if (name === 'price' && val && parseFloat(val) <= 0) {
    showError(el, 'Price must be greater than 0'); return false;
  }
  if (name === 'stock' && val && parseInt(val) < 0) {
    showError(el, 'Stock cannot be negative'); return false;
  }
  if (name === 'quantity' && val && parseInt(val) < 1) {
    showError(el, 'Quantity must be at least 1'); return false;
  }

  showOk(el);
  return true;
}
