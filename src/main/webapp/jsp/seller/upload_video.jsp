<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html><html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Upload Video - IDUKA</title>
<jsp:include page="../common/css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
.video-drop-zone{border:2px dashed var(--border);border-radius:var(--radius);padding:50px 30px;text-align:center;cursor:pointer;color:var(--text-light);transition:all .2s;background:#fafafa}
.video-drop-zone:hover,.video-drop-zone.drag-over{border-color:var(--primary);color:var(--primary);background:rgba(108,99,255,.04)}
.video-drop-zone.has-file{border-color:#43e97b;background:rgba(67,233,123,.05)}
.progress-bar-wrap{display:none;background:#e0e0e0;border-radius:50px;height:8px;margin-top:12px;overflow:hidden}
.progress-bar{height:100%;background:linear-gradient(135deg,var(--primary),var(--secondary));width:0;transition:width .3s;border-radius:50px}
.video-preview{width:100%;max-height:200px;border-radius:var(--radius);margin-top:12px;display:none}
</style>
</head>
<body><jsp:include page="../common/header.jsp"/>
<div class="container mt-4"><div class="form-card">
  <h2><i class="fas fa-video"></i> Upload Product Video</h2>
  <p class="form-hint"><i class="fas fa-info-circle"></i> Upload short videos showcasing your product (TikTok style). Buyers scroll through these videos!</p>
  <c:if test="${not empty error}"><div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ${error}</div></c:if>
  <form method="post" action="<%=ctx%>/seller/uploadVideo" enctype="multipart/form-data" class="auth-form" id="videoForm">
    <div class="form-group">
      <label>Select Product to Showcase *</label>
      <select name="productId" required>
        <option value="">-- Select your product --</option>
        <c:forEach var="p" items="${sellerProducts}">
        <option value="${p.id}">${p.name} — RWF ${p.price}</option>
        </c:forEach>
      </select>
      <c:if test="${empty sellerProducts}">
        <div class="alert alert-danger" style="margin-top:8px"><i class="fas fa-exclamation-triangle"></i> You have no products yet. <a href="<%=ctx%>/seller/addProduct">Add a product first!</a></div>
      </c:if>
    </div>
    <div class="form-group">
      <label>Video Title *</label>
      <input type="text" name="title" placeholder="e.g. 🥑 Fresh avocados from Musanze farm — RWF 2000/kg!" required maxlength="200">
    </div>
    <div class="form-group">
      <label>Video File * <small style="color:var(--text-light)">(MP4, MOV, AVI, WEBM — max 100MB)</small></label>
      <div class="video-drop-zone" id="videoDropZone" onclick="document.getElementById('videoFile').click()">
        <i class="fas fa-cloud-upload-alt fa-3x" style="margin-bottom:12px;display:block"></i>
        <p style="font-size:1rem;font-weight:600">Click to select video</p>
        <small>MP4, MOV, AVI, WEBM — max 100MB</small>
      </div>
      <input type="file" name="video" id="videoFile" accept="video/mp4,video/quicktime,video/x-msvideo,video/webm,video/*" required style="display:none">
      <video id="videoPreview" class="video-preview" controls></video>
      <div class="progress-bar-wrap" id="progressWrap"><div class="progress-bar" id="progressBar"></div></div>
      <div id="videoFileInfo" style="font-size:.85rem;color:var(--text-light);margin-top:6px"></div>
    </div>
    <div class="form-actions">
      <a href="<%=ctx%>/seller/dashboard" class="btn-outline">Cancel</a>
      <button type="submit" class="btn-primary" id="uploadBtn"><i class="fas fa-upload"></i> Upload Video</button>
    </div>
  </form>
</div></div>

<script>
const videoFile = document.getElementById('videoFile');
const dropZone = document.getElementById('videoDropZone');
const videoPreview = document.getElementById('videoPreview');
const fileInfo = document.getElementById('videoFileInfo');

videoFile.addEventListener('change', function() {
    const file = this.files[0];
    if (!file) return;
    if (file.size > 100 * 1024 * 1024) {
        alert('Video too large. Max 100MB.');
        this.value = '';
        return;
    }
    const url = URL.createObjectURL(file);
    videoPreview.src = url;
    videoPreview.style.display = 'block';
    fileInfo.textContent = file.name + ' (' + (file.size/1024/1024).toFixed(1) + ' MB)';
    dropZone.classList.add('has-file');
    dropZone.innerHTML = '<i class="fas fa-check-circle fa-3x" style="color:#43e97b;margin-bottom:12px;display:block"></i><p style="font-weight:600">Video selected!</p><small>Click to change</small>';
});

// Drag & drop
dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('drag-over'); });
dropZone.addEventListener('dragleave', () => dropZone.classList.remove('drag-over'));
dropZone.addEventListener('drop', e => {
    e.preventDefault();
    dropZone.classList.remove('drag-over');
    if (e.dataTransfer.files[0]) { videoFile.files = e.dataTransfer.files; videoFile.dispatchEvent(new Event('change')); }
});

// Show upload progress simulation
document.getElementById('videoForm').addEventListener('submit', function() {
    const btn = document.getElementById('uploadBtn');
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Uploading... please wait';
    btn.disabled = true;
    document.getElementById('progressWrap').style.display = 'block';
    let w = 0;
    const iv = setInterval(() => { w = Math.min(w + 2, 90); document.getElementById('progressBar').style.width = w + '%'; if (w >= 90) clearInterval(iv); }, 200);
});
</script>
</body></html>
