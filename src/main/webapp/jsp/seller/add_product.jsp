<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add Product - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.img-drop-zone{border:2px dashed var(--border);border-radius:var(--radius);padding:30px;text-align:center;cursor:pointer;color:var(--text-light);transition:all .2s;background:#fafafa}
.img-drop-zone:hover{border-color:var(--primary);color:var(--primary);background:rgba(108,99,255,.04)}
.img-drop-zone.has-file{border-color:var(--accent);background:rgba(67,233,123,.05)}
.img-preview-wrap{margin-top:12px;display:none;text-align:center}
.img-preview-wrap img{max-height:200px;max-width:100%;border-radius:var(--radius);border:2px solid var(--border)}
.file-info{font-size:.85rem;color:var(--text-light);margin-top:6px}
</style>
</head>
<body><jsp:include page="../common/header.jsp"/>
<div class="container mt-4"><div class="form-card">
  <h2><i class="fas fa-plus-circle"></i> Add New Product</h2>
  <c:if test="${not empty error}"><div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${error}</div></c:if>
  <form method="post" action="<%=ctx%>/seller/addProduct" enctype="multipart/form-data" class="auth-form" id="productForm" novalidate>
    <div class="form-row">
      <div class="form-group">
        <label>Product Name *</label>
        <input type="text" name="name" placeholder="e.g. Fresh Avocados 1kg" required>
      </div>
      <div class="form-group">
        <label>Category *</label>
        <select name="categoryId" required>
          <option value="">-- Select Category --</option>
          <c:forEach var="cat" items="${categories}">
          <option value="${cat.id}">${cat.name}</option>
          </c:forEach>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label>Description</label>
      <textarea name="description" rows="4" placeholder="Describe your product in detail — quality, size, origin, etc."></textarea>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Price (RWF) *</label>
        <input type="number" name="price" placeholder="e.g. 5000" min="1" step="1" required>
      </div>
      <div class="form-group">
        <label>Stock Quantity *</label>
        <input type="number" name="stock" placeholder="e.g. 50" min="0" required>
      </div>
    </div>
    <div class="form-group">
      <label>Product Image <small style="color:var(--text-light)">(JPG, PNG, GIF — max 10MB)</small></label>
      <div class="img-drop-zone" id="dropZone" onclick="document.getElementById('imgFile').click()">
        <i class="fas fa-image fa-2x" style="margin-bottom:8px;display:block"></i>
        <p>Click to select image</p>
        <small>JPG, PNG, GIF, WEBP — max 10MB</small>
      </div>
      <input type="file" name="image" id="imgFile" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none">
      <div class="img-preview-wrap" id="previewWrap">
        <img id="imgPreview" src="" alt="Preview">
        <div class="file-info" id="fileInfo"></div>
      </div>
    </div>
    <div class="form-actions">
      <a href="<%=ctx%>/seller/dashboard" class="btn-outline">Cancel</a>
      <button type="submit" class="btn-primary" id="submitBtn">Add Product <i class="fas fa-plus"></i></button>
    </div>
  </form>
</div></div>

<script>
const imgFile = document.getElementById('imgFile');
const dropZone = document.getElementById('dropZone');
const previewWrap = document.getElementById('previewWrap');
const imgPreview = document.getElementById('imgPreview');
const fileInfo = document.getElementById('fileInfo');

imgFile.addEventListener('change', function() {
    const file = this.files[0];
    if (!file) return;
    // Validate size
    if (file.size > 10 * 1024 * 1024) {
        alert('Image too large. Max 10MB.');
        this.value = '';
        return;
    }
    const reader = new FileReader();
    reader.onload = function(e) {
        imgPreview.src = e.target.result;
        previewWrap.style.display = 'block';
        fileInfo.textContent = file.name + ' (' + (file.size/1024).toFixed(1) + ' KB)';
        dropZone.classList.add('has-file');
        dropZone.innerHTML = '<i class="fas fa-check-circle fa-2x" style="color:#43e97b;margin-bottom:8px;display:block"></i><p>Image selected!</p><small>Click to change</small>';
    };
    reader.readAsDataURL(file);
});

// Drag & drop support
dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.style.borderColor='var(--primary)'; });
dropZone.addEventListener('dragleave', () => { dropZone.style.borderColor='var(--border)'; });
dropZone.addEventListener('drop', e => {
    e.preventDefault();
    dropZone.style.borderColor='var(--border)';
    if (e.dataTransfer.files[0]) { imgFile.files = e.dataTransfer.files; imgFile.dispatchEvent(new Event('change')); }
});

// Show loading on submit
document.getElementById('productForm').addEventListener('submit', function() {
    document.getElementById('submitBtn').innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading...';
    document.getElementById('submitBtn').disabled = true;
});
</script>
<script src="<%=ctx%>/js/validate.js"></script>
</body></html>
