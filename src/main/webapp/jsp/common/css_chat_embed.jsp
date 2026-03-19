<%@ page contentType="text/html;charset=UTF-8" %><style>
/* Chat Styles */
.chat-page-wrap { max-width:800px; margin:0 auto; padding:20px; display:flex; flex-direction:column; height:calc(100vh - 65px); }
.chat-header-bar { display:flex; align-items:center; gap:12px; background:#fff; padding:16px; border-radius:var(--radius); margin-bottom:12px; box-shadow:var(--shadow); }
.back-btn { color:var(--primary); text-decoration:none; font-size:1.1rem; padding:6px; }
.chat-user-info { flex:1; }
.chat-user-info strong { display:block; font-weight:700; }
.chat-user-info span { font-size:0.8rem; color:var(--text-light); }
.chat-avatar-icon { font-size:2rem; color:var(--primary); }
.view-product-btn { background:var(--bg); color:var(--text); padding:7px 14px; border-radius:50px; text-decoration:none; font-size:0.85rem; font-weight:600; border:1px solid var(--border); }
.chat-messages { flex:1; overflow-y:auto; background:#fff; border-radius:var(--radius); padding:20px; margin-bottom:12px; box-shadow:var(--shadow); display:flex; flex-direction:column; gap:12px; }
.chat-notice { text-align:center; background:rgba(108,99,255,0.08); color:var(--primary); padding:10px 16px; border-radius:50px; font-size:0.85rem; margin-bottom:8px; }
.chat-bubble { max-width:70%; }
.chat-bubble.sent { align-self:flex-end; }
.chat-bubble.received { align-self:flex-start; }
.bubble-name { font-size:0.75rem; color:var(--text-light); margin-bottom:3px; }
.bubble-text { padding:10px 14px; border-radius:12px; font-size:0.9rem; line-height:1.5; }
.sent .bubble-text { background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; border-radius:12px 12px 0 12px; }
.received .bubble-text { background:var(--bg); color:var(--text); border-radius:12px 12px 12px 0; }
.bubble-time { font-size:0.72rem; color:var(--text-light); margin-top:3px; }
.sent .bubble-time { text-align:right; }
.chat-start-hint { text-align:center; color:var(--text-light); padding:40px 0; }
.chat-start-hint i { font-size:2.5rem; display:block; margin-bottom:10px; }
.chat-input-form { flex-shrink:0; }
.chat-input-wrap { display:flex; gap:10px; background:#fff; padding:12px; border-radius:50px; box-shadow:var(--shadow); }
.chat-input-wrap input { flex:1; border:none; outline:none; font-size:0.95rem; font-family:inherit; padding:6px 10px; }
.chat-input-wrap button { background:var(--primary); color:#fff; border:none; padding:10px 20px; border-radius:50px; cursor:pointer; font-size:1rem; transition:all 0.2s; }
.chat-input-wrap button:hover { background:var(--primary-dark); }
.inbox-list { background:#fff; border-radius:var(--radius); box-shadow:var(--shadow); overflow:hidden; }
.inbox-item { display:flex; align-items:center; gap:14px; padding:16px 20px; text-decoration:none; color:var(--text); border-bottom:1px solid var(--bg); transition:background 0.2s; }
.inbox-item:hover { background:rgba(108,99,255,0.04); }
.inbox-avatar i { font-size:2rem; color:var(--primary); }
.inbox-info { flex:1; }
.inbox-info strong { display:block; font-weight:700; }
.inbox-product { font-size:0.8rem; color:var(--text-light); }
.inbox-time { font-size:0.78rem; color:var(--text-light); }
</style>
