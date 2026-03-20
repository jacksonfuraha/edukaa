<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Edit Product - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.edit-wrap{max-width:700px;margin:30px auto;padding:0 16px}
.edit-card{background:#fff;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,.08);overflow:hidden}
.edit-header{background:linear-gradient(135deg,#6c63ff,#a78bfa);color:#fff;padding:24px 28px}
.edit-header h2{margin:0;font-size:1.3rem}
.edit-header p{margin:6px 0 0;opacity:.8;font-size:.88rem}
.edit-body{padding:28px}
.img-preview-wrap{position:relative;display:inline-block;margin-bottom:16px}
.img-preview{width:120px;height:120px;object-fit:cover;border-radius:12px;border:3px solid #e8e0ff}
.img-change-btn{position:absolute;bottom:-8px;right:-8px;background:#6c63ff;color:#fff;
  border:none;border-radius:50%;width:32px;height:32px;cursor:pointer;font-size:.8rem;
  display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(108,99,255,.4)}
.active-toggle{display:flex;align-items:center;gap:10px;padding:12px 0}
.toggle-switch{position:relative;width:46px;height:24px}
.toggle-switch input{opacity:0;width:0;height:0}
.toggle-slider{position:absolute;inset:0;background:#ccc;border-radius:50px;cursor:pointer;transition:.3s}
.toggle-slider:before{content:"";position:absolute;width:18px;height:18px;left:3px;top:3px;background:#fff;border-radius:50%;transition:.3s}
.toggle-switch input:checked+.toggle-slider{background:#27ae60}
.toggle-switch input:checked+.toggle-slider:before{transform:translateX(22px)}
.btn-row{display:flex;gap:12px;margin-top:24px;flex-wrap:wrap}
.btn-save{background:#6c63ff;color:#fff;border:none;padding:12px 28px;border-radius:10px;
  font-size:.95rem;font-weight:600;cursor:pointer;flex:1}
.btn-save:hover{background:#5a52e0}
.btn-cancel{background:#f5f5f5;color:#555;border:none;padding:12px 20px;border-radius:10px;
  font-size:.95rem;font-weight:600;cursor:pointer;text-decoration:none;text-align:center}
.btn-cancel:hover{background:#ebebeb}
.btn-delete{background:#fff0f0;color:#e74c3c;border:1px solid #fca5a5;padding:12px 20px;
  border-radius:10px;font-size:.95rem;font-weight:600;cursor:pointer;text-decoration:none;text-align:center}
.btn-delete:hover{background:#fee2e2}
</style>
</head>
<body>
<jsp:include page="../common/header.jsp"/>
<div class="edit-wrap">
  <div class="edit-card">
    <div class="edit-header">
      <h2><i class="fas fa-edit"></i> Edit Product</h2>
      <p>Update your product details, price, stock or image</p>
    </div>
    <div class="edit-body">

      <%-- Current image preview --%>
      <div class="img-preview-wrap">
        <img id="imgPreview"
             src="${empty product.imageUrl ? ctx.concat('/images/no-image.svg') : ctx.concat('/uploads/').concat(product.imageUrl)}"
             class="img-preview" alt="Product image"
             onerror="this.onerror=null;this.src='<%=ctx%>/images/no-image.svg'">
        <button type="button" class="img-change-btn" title="Change image"
                onclick="document.getElementById('imgInput').click()">
          <i class="fas fa-camera"></i>
        </button>
      </div>

      <form method="post" action="<%=ctx%>/seller/editProduct" enctype="multipart/form-data" id="editForm">
        <input type="hidden" name="id" value="${product.id}">
        <input type="file" name="image" id="imgInput" accept="image/*" style="display:none"
               onchange="previewImg(this)">

        <div class="form-row" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
          <div class="form-group">
            <label>Product Name *</label>
            <input type="text" name="name" value="${product.name}" required>
          </div>
          <div class="form-group">
            <label>Category</label>
            <select name="categoryId" class="form-control">
              <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" ${cat.id == product.categoryId ? 'selected' : ''}>${cat.name}</option>
              </c:forEach>
            </select>
          </div>
        </div>

        <div class="form-group">
          <label>Description</label>
          <textarea name="description" rows="3" style="resize:vertical">${product.description}</textarea>
        </div>

        <div class="form-row" style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
          <div class="form-group">
            <label>Price (RWF) *</label>
            <input type="number" name="price" value="${product.price}" min="0" step="100" required>
          </div>
          <div class="form-group">
            <label>Stock Quantity *</label>
            <input type="number" name="stock" value="${product.stock}" min="0" required>
          </div>
        </div>

        <div class="active-toggle">
          <label class="toggle-switch">
            <input type="checkbox" name="active" id="activeToggle" ${product.active ? 'checked' : ''}>
            <span class="toggle-slider"></span>
          </label>
          <span id="activeLabel" style="font-size:.9rem;font-weight:600;color:#333">
            ${product.active ? 'Active (visible to buyers)' : 'Inactive (hidden from buyers)'}
          </span>
        </div>

        <div class="btn-row">
          <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save Changes</button>
          <a href="<%=ctx%>/seller/dashboard" class="btn-cancel"><i class="fas fa-times"></i> Cancel</a>
          <a href="<%=ctx%>/seller/editProduct?action=delete&id=${product.id}"
             class="btn-delete" onclick="return confirm('Delete this product? This cannot be undone.')">
            <i class="fas fa-trash"></i> Delete
          </a>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
function previewImg(input) {
  if (!input.files[0]) return;
  var reader = new FileReader();
  reader.onload = function(e) {
    document.getElementById('imgPreview').src = e.target.result;
  };
  reader.readAsDataURL(input.files[0]);
}
document.getElementById('activeToggle').addEventListener('change', function(){
  document.getElementById('activeLabel').textContent =
    this.checked ? 'Active (visible to buyers)' : 'Inactive (hidden from buyers)';
  document.getElementById('activeLabel').style.color = this.checked ? '#27ae60' : '#e74c3c';
});
</script>
</body></html>
