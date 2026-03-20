<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Videos - IDUKA</title>
<jsp:include page="css_embed.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
*{margin:0;padding:0;box-sizing:border-box}
body.videos-body{background:#000;overflow:hidden}
.vpage{display:flex;height:100vh;width:100vw}

/* Feed */
.vfeed-wrap{flex:1;height:100vh;overflow-y:scroll;scroll-snap-type:y mandatory}
.vfeed-wrap::-webkit-scrollbar{display:none}
.vslide{height:100vh;scroll-snap-align:start;position:relative;display:flex;align-items:center;justify-content:center;background:#111}
.vplayer{width:100%;height:100%;max-width:420px;object-fit:contain;cursor:pointer;display:block}

/* Play overlay */
.vplay-overlay{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;pointer-events:none}
.vplay-circle{width:72px;height:72px;border-radius:50%;background:rgba(0,0,0,.55);display:flex;align-items:center;justify-content:center;transition:opacity .3s}
.vplay-circle i{color:#fff;font-size:1.8rem;margin-left:4px}
.vslide.playing .vplay-circle{opacity:0}

/* Progress */
.vprogress-wrap{position:absolute;bottom:0;left:0;right:0;height:3px;background:rgba(255,255,255,.2);cursor:pointer}
.vprogress-bar{height:100%;background:#6c63ff;width:0%;pointer-events:none}

/* Info */
.vinfo{position:absolute;bottom:0;left:0;right:70px;padding:20px 16px;background:linear-gradient(transparent,rgba(0,0,0,.8));color:#fff}
.vinfo .vseller{font-size:.82rem;opacity:.75;margin-bottom:4px}
.vinfo .vtitle{font-weight:700;font-size:1rem;margin-bottom:10px;line-height:1.3}
.vbuy{display:inline-block;background:#6c63ff;color:#fff;padding:7px 18px;border-radius:50px;font-size:.82rem;font-weight:600;text-decoration:none}
.vbuy:hover{background:#5a52e0}

/* Actions */
.vactions{position:absolute;right:10px;bottom:80px;display:flex;flex-direction:column;gap:16px;align-items:center}
.vact-btn{background:none;border:none;color:#fff;display:flex;flex-direction:column;align-items:center;gap:3px;font-size:.68rem;cursor:pointer;text-decoration:none;min-width:44px}
.vact-btn i{font-size:1.6rem;filter:drop-shadow(0 1px 3px rgba(0,0,0,.5))}
.vact-btn span{font-size:.72rem;font-weight:600}
.vact-btn.liked i{color:#e74c3c}
.vact-btn:hover i{transform:scale(1.1)}

/* ── Comment panel ── */
.vcomment-panel{
  position:fixed;top:0;right:0;width:340px;height:100vh;
  background:#1a1a2e;color:#fff;z-index:500;
  display:flex;flex-direction:column;
  transform:translateX(100%);transition:transform .3s ease;
}
.vcomment-panel.open{transform:translateX(0)}
.vcp-header{display:flex;justify-content:space-between;align-items:center;padding:16px;border-bottom:1px solid rgba(255,255,255,.1)}
.vcp-header h3{font-size:.95rem;color:#a78bfa}
.vcp-close{background:none;border:none;color:#fff;font-size:1.2rem;cursor:pointer}
.vcp-list{flex:1;overflow-y:auto;padding:12px}
.vcp-list::-webkit-scrollbar{width:4px}
.vcp-list::-webkit-scrollbar-thumb{background:rgba(255,255,255,.1);border-radius:4px}
.vcp-item{display:flex;gap:10px;margin-bottom:14px}
.vcp-avatar{width:34px;height:34px;border-radius:50%;background:#6c63ff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.85rem;flex-shrink:0;overflow:hidden}
.vcp-avatar img{width:100%;height:100%;object-fit:cover}
.vcp-body{}
.vcp-name{font-size:.78rem;color:#a78bfa;font-weight:600;margin-bottom:2px}
.vcp-text{font-size:.85rem;color:rgba(255,255,255,.9);line-height:1.4}
.vcp-time{font-size:.7rem;color:rgba(255,255,255,.35);margin-top:2px}
.vcp-empty{text-align:center;padding:30px 16px;color:rgba(255,255,255,.25);font-size:.85rem}
.vcp-footer{padding:12px;border-top:1px solid rgba(255,255,255,.1);display:flex;gap:8px}
.vcp-input{flex:1;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.15);border-radius:20px;padding:8px 14px;color:#fff;font-size:.88rem;outline:none}
.vcp-input:focus{border-color:#6c63ff}
.vcp-input::placeholder{color:rgba(255,255,255,.3)}
.vcp-send{background:#6c63ff;border:none;color:#fff;width:36px;height:36px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;flex-shrink:0}
.vcp-send:hover{background:#5a52e0}
.vcp-login-note{text-align:center;padding:12px;font-size:.8rem;color:rgba(255,255,255,.4)}
.vcp-login-note a{color:#a78bfa}

/* Sidebar */
.vsidebar{width:200px;background:#1a1a2e;color:#fff;padding:24px 16px;display:flex;flex-direction:column;gap:14px;overflow-y:auto}
.vsidebar h3{font-size:.95rem;color:#a78bfa}
.vsidebar p{font-size:.8rem;color:rgba(255,255,255,.5);line-height:1.5}
.v-upload-btn{background:#6c63ff;color:#fff;padding:10px 14px;border-radius:8px;text-align:center;text-decoration:none;font-size:.82rem;font-weight:600}
.vsidebar-logo{display:flex;align-items:center;gap:8px;margin-bottom:4px}
.vsidebar-logo .lm{background:#6c63ff;color:#fff;width:30px;height:30px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-weight:700}
@media(max-width:600px){.vsidebar{display:none}}
.v-home-mobile{display:none;position:fixed;top:14px;left:14px;z-index:999;background:#27ae60;color:#fff;border:none;border-radius:50px;padding:8px 16px;font-size:.82rem;font-weight:700;cursor:pointer;text-decoration:none;align-items:center;gap:6px;box-shadow:0 4px 14px rgba(0,0,0,.4)}
@media(max-width:600px){.v-home-mobile{display:flex}}

/* Success banner */
.vsuccess{position:fixed;top:0;left:0;right:0;z-index:999;background:#27ae60;color:#fff;padding:10px;text-align:center;font-size:.88rem}
</style>
</head>
<body class="videos-body">

<%-- Mobile Home Button (visible only on small screens where sidebar is hidden) --%>
<a href="<%=ctx%>/home" class="v-home-mobile"><i class="fas fa-home"></i> Home</a>

<c:if test="${not empty param.success}">
  <div class="vsuccess"><i class="fas fa-check-circle"></i> ${param.success}</div>
</c:if>

<div class="vpage">
  <%-- Video Feed --%>
  <div class="vfeed-wrap" id="vfeedWrap">

    <c:forEach var="video" items="${videos}" varStatus="st">
    <%
      java.util.Set<Integer> liked = (java.util.Set<Integer>)request.getAttribute("likedVideoIds");
      boolean isLiked = liked != null && liked.contains(((com.iduka.model.ProductVideo)pageContext.getAttribute("video")).getId());
      pageContext.setAttribute("isLiked", isLiked);
    %>
    <div class="vslide" id="vslide-${st.index}" data-idx="${st.index}">

      <video class="vplayer" id="vplayer-${st.index}"
             preload="metadata" playsinline muted loop
             src="${video.videoUrl.startsWith('http') ? video.videoUrl : pageContext.request.contextPath.concat('/uploads/').concat(video.videoUrl)}"
             onclick="toggleVid(${st.index})">
      </video>

      <div class="vplay-overlay">
        <div class="vplay-circle" id="vplaycircle-${st.index}">
          <i class="fas fa-play" id="vplayicon-${st.index}"></i>
        </div>
      </div>

      <div class="vprogress-wrap" onclick="seekVid(event,${st.index})">
        <div class="vprogress-bar" id="vprog-${st.index}"></div>
      </div>

      <div class="vinfo">
        <div class="vseller"><i class="fas fa-store"></i> ${video.sellerName}</div>
        <div class="vtitle">${video.title}</div>
        <a href="<%=ctx%>/product?id=${video.productId}" class="vbuy">
          <i class="fas fa-shopping-bag"></i> See Product
        </a>
      </div>

      <div class="vactions">
        <%-- Like button - server knows if user already liked --%>
        <button class="vact-btn ${isLiked ? 'liked' : ''}"
                id="likebtn-${video.id}"
                onclick="toggleLike(${video.id}, this)">
          <i class="fas fa-heart"></i>
          <span id="likecount-${video.id}">${video.likes}</span>
        </button>

        <%-- Comments --%>
        <button class="vact-btn" onclick="openComments(${video.id}, this.getAttribute('data-title'))" data-title="${video.title}">
          <i class="fas fa-comment-dots"></i>
          <span id="cmtcount-${video.id}">${video.commentCount}</span>
        </button>

        <%-- Chat with seller --%>
        <c:if test="${sessionScope.userRole == 'BUYER'}">
        <a href="<%=ctx%>/chat?userId=${video.sellerId}&productId=${video.productId}" class="vact-btn">
          <i class="fas fa-comments"></i><span>Chat</span>
        </a>
        </c:if>

        <%-- Buy --%>
        <a href="<%=ctx%>/product?id=${video.productId}" class="vact-btn">
          <i class="fas fa-cart-plus"></i><span>Buy</span>
        </a>

        <%-- Sound --%>
        <button class="vact-btn" onclick="toggleMute(${st.index},this)">
          <i class="fas fa-volume-mute" id="vmute-${st.index}"></i>
          <span>Sound</span>
        </button>
      </div>
    </div>
    </c:forEach>

    <c:if test="${empty videos}">
    <div class="vslide" style="color:#fff;text-align:center">
      <div>
        <i class="fas fa-video" style="font-size:3rem;opacity:.3;display:block;margin-bottom:16px"></i>
        <h3 style="opacity:.5">No videos yet</h3>
        <c:if test="${sessionScope.userRole == 'SELLER'}">
          <a href="<%=ctx%>/seller/uploadVideo" style="display:inline-block;margin-top:20px;background:#6c63ff;color:#fff;padding:10px 24px;border-radius:50px;text-decoration:none">
            <i class="fas fa-plus"></i> Upload First Video
          </a>
        </c:if>
      </div>
    </div>
    </c:if>
  </div>

  <%-- Sidebar --%>
  <div class="vsidebar">
    <div class="vsidebar-logo">
      <div class="lm">I</div>
      <strong>IDUKA</strong>
    </div>
    <a href="<%=ctx%>/home" class="v-upload-btn" style="background:#27ae60;display:flex;align-items:center;gap:8px;justify-content:center">
      <i class="fas fa-home"></i> Home
    </a>
    <h3><i class="fas fa-fire"></i> Product Reels</h3>
    <p>Swipe through product videos from sellers across Rwanda.</p>
    <c:if test="${sessionScope.userRole == 'SELLER'}">
      <a href="<%=ctx%>/seller/uploadVideo" class="v-upload-btn"><i class="fas fa-plus"></i> Upload Video</a>
    </c:if>
    <c:if test="${empty sessionScope.user}">
      <a href="<%=ctx%>/login" class="v-upload-btn" style="background:#444;margin-top:8px">Login</a>
    </c:if>
  </div>
</div>

<%-- Comment panel (shared, loaded dynamically) --%>
<div class="vcomment-panel" id="commentPanel">
  <div class="vcp-header">
    <h3 id="cpTitle"><i class="fas fa-comment-dots"></i> Comments</h3>
    <button class="vcp-close" onclick="closeComments()"><i class="fas fa-times"></i></button>
  </div>
  <div class="vcp-list" id="cpList">
    <div class="vcp-empty">Loading comments…</div>
  </div>
  <c:choose>
    <c:when test="${not empty sessionScope.user}">
      <div class="vcp-footer">
        <input class="vcp-input" id="cpInput" placeholder="Write a comment…" maxlength="300"
               onkeydown="if(event.key==='Enter')postComment()">
        <button class="vcp-send" onclick="postComment()"><i class="fas fa-paper-plane"></i></button>
      </div>
    </c:when>
    <c:otherwise>
      <div class="vcp-login-note"><a href="<%=ctx%>/login">Login</a> to comment</div>
    </c:otherwise>
  </c:choose>
</div>

<script>
var CTX = '<%=ctx%>';
var currentIdx   = -1;
var currentVideoId = 0;

// ── Video playback ────────────────────────────────────────────────────
function getVid(i)  { return document.getElementById('vplayer-'+i); }
function getSlide(i){ return document.getElementById('vslide-'+i); }
function getIcon(i) { return document.getElementById('vplayicon-'+i); }
function getProg(i) { return document.getElementById('vprog-'+i); }
function getMuteI(i){ return document.getElementById('vmute-'+i); }

function toggleVid(i) {
  var v = getVid(i);
  if (!v) return;
  if (v.paused) playVid(i); else pauseVid(i);
}
function playVid(i) {
  if (currentIdx !== -1 && currentIdx !== i) pauseVid(currentIdx);
  var v = getVid(i), slide = getSlide(i), icon = getIcon(i);
  if (!v) return;
  v.muted = false;
  if (getMuteI(i)) getMuteI(i).className = 'fas fa-volume-up';
  v.play().then(function(){
    if (slide) slide.classList.add('playing');
    if (icon)  icon.className = 'fas fa-pause';
    currentIdx = i;
  }).catch(function(){
    v.muted = true;
    v.play().then(function(){
      if (slide) slide.classList.add('playing');
      if (icon)  icon.className = 'fas fa-pause';
      currentIdx = i;
    }).catch(function(){});
  });
}
function pauseVid(i) {
  var v = getVid(i);
  if (v && !v.paused) v.pause();
  var slide = getSlide(i), icon = getIcon(i);
  if (slide) slide.classList.remove('playing');
  if (icon)  icon.className = 'fas fa-play';
}

// Progress bars
document.querySelectorAll('.vplayer').forEach(function(v){
  v.addEventListener('timeupdate', function(){
    var i = v.id.replace('vplayer-','');
    var p = getProg(i);
    if (p && v.duration) p.style.width = ((v.currentTime/v.duration)*100)+'%';
  });
});
function seekVid(e,i){
  var v = getVid(i); if (!v||!v.duration) return;
  var r = e.currentTarget.getBoundingClientRect();
  v.currentTime = ((e.clientX-r.left)/r.width)*v.duration;
}
function toggleMute(i,btn){
  var v=getVid(i); if(!v)return;
  v.muted=!v.muted;
  var ic=getMuteI(i);
  if(ic) ic.className=v.muted?'fas fa-volume-mute':'fas fa-volume-up';
}

// IntersectionObserver
if ('IntersectionObserver' in window) {
  var obs = new IntersectionObserver(function(entries){
    entries.forEach(function(e){
      var i = parseInt(e.target.getAttribute('data-idx'));
      if (e.isIntersecting && e.intersectionRatio >= 0.8) playVid(i);
      else pauseVid(i);
    });
  },{threshold:0.8});
  document.querySelectorAll('.vslide').forEach(function(s){ obs.observe(s); });
}

// ── Likes ─────────────────────────────────────────────────────────────
function toggleLike(videoId, btn) {
  fetch(CTX+'/videos/like', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'videoId='+videoId,
    credentials:'same-origin'
  })
  .then(function(r){ return r.json(); })
  .then(function(data){
    var countEl = document.getElementById('likecount-'+videoId);
    if (countEl) countEl.textContent = data.likes;
    if (data.liked) btn.classList.add('liked');
    else            btn.classList.remove('liked');
  })
  .catch(function(){ /* offline */ });
}

// ── Comments ──────────────────────────────────────────────────────────
var activeVideoId = 0;

function openComments(videoId, title) {
  activeVideoId = videoId;
  document.getElementById('cpTitle').innerHTML = '<i class="fas fa-comment-dots"></i> ' + (title || 'Comments');
  document.getElementById('cpList').innerHTML = '<div class="vcp-empty">Loading…</div>';
  document.getElementById('commentPanel').classList.add('open');
  loadComments(videoId);
}
function closeComments() {
  document.getElementById('commentPanel').classList.remove('open');
}
function loadComments(videoId) {
  fetch(CTX+'/videos/comment?videoId='+videoId, {credentials:'same-origin'})
  .then(function(r){ return r.json(); })
  .then(function(list){
    renderComments(list);
    // Update comment count badge
    var el = document.getElementById('cmtcount-'+videoId);
    if (el) el.textContent = list.length;
  })
  .catch(function(){ document.getElementById('cpList').innerHTML='<div class="vcp-empty">Failed to load.</div>'; });
}

function renderComments(list) {
  var box = document.getElementById('cpList');
  if (!list || list.length === 0) {
    box.innerHTML = '<div class="vcp-empty"><i class="fas fa-comment-slash" style="display:block;font-size:2rem;margin-bottom:8px"></i>No comments yet. Be first!</div>';
    return;
  }
  box.innerHTML = list.map(function(c){
    var initial = c.userName ? c.userName.charAt(0).toUpperCase() : '?';
    var avatar  = c.avatarUrl
      ? '<img src="'+CTX+'/uploads/'+c.avatarUrl+'" alt="">'
      : initial;
    var time = c.time ? new Date(c.time).toLocaleDateString() : '';
    return '<div class="vcp-item">' +
      '<div class="vcp-avatar">'+avatar+'</div>' +
      '<div class="vcp-body">' +
        '<div class="vcp-name">'+escHtml(c.userName)+'</div>' +
        '<div class="vcp-text">'+escHtml(c.comment)+'</div>' +
        '<div class="vcp-time">'+time+'</div>' +
      '</div></div>';
  }).join('');
  box.scrollTop = box.scrollHeight;
}

function postComment() {
  var input = document.getElementById('cpInput');
  var text  = input ? input.value.trim() : '';
  if (!text || !activeVideoId) return;
  input.value = '';
  fetch(CTX+'/videos/comment', {
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded'},
    body:'videoId='+activeVideoId+'&comment='+encodeURIComponent(text),
    credentials:'same-origin'
  })
  .then(function(r){ return r.json(); })
  .then(function(data){
    if (data.error === 'login_required') {
      window.location.href = CTX+'/login'; return;
    }
    if (data.id) {
      // Append new comment
      loadComments(activeVideoId);
    }
  })
  .catch(function(){});
}

function escHtml(s) {
  if (!s) return '';
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ── Refresh all comment counts on page load ────────────────────────────────
(function refreshAllCounts() {
  // Collect all video IDs from the page
  var videoBtns = document.querySelectorAll('[id^="cmtcount-"]');
  videoBtns.forEach(function(el) {
    var videoId = el.id.replace('cmtcount-', '');
    if (!videoId) return;
    fetch(CTX + '/videos/comment?videoId=' + videoId, { credentials: 'same-origin' })
      .then(function(r) { return r.json(); })
      .then(function(list) {
        el.textContent = list.length;
      })
      .catch(function() {});
  });
})();
</script>
</body>
</html>
