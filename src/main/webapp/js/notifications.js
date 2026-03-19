/**
 * IDUKA Notification System
 * Polls /notifications every 5s and updates:
 *   - Bell badge (red number on bell icon)
 *   - Chat badge (red number on Chats link)
 *   - Dropdown list of notifications
 *   - Toast popup when new notification arrives
 */
(function () {
  'use strict';
  var CTX        = window.IDUKA_CTX || '';
  var prevCount  = -1;   // -1 = first load, don't play sound
  var audioCtx   = null;

  /* ── helpers ─────────────────────────────────────────── */
  function $(id) { return document.getElementById(id); }

  function showBadge(el, count) {
    if (!el) return;
    if (count > 0) {
      el.textContent = count > 99 ? '99+' : String(count);
      el.classList.remove('hidden');
    } else {
      el.classList.add('hidden');
    }
  }

  function iconFor(type) {
    return { ORDER: '🛒', ORDER_STATUS: '📦', MESSAGE: '💬', LIKE: '❤️' }[type] || '🔔';
  }

  function timeAgo(str) {
    if (!str) return '';
    var d    = new Date(str.replace(' ', 'T'));
    var diff = Math.floor((Date.now() - d.getTime()) / 1000);
    if (diff < 60)    return 'just now';
    if (diff < 3600)  return Math.floor(diff / 60) + 'm ago';
    if (diff < 86400) return Math.floor(diff / 3600) + 'h ago';
    return Math.floor(diff / 86400) + 'd ago';
  }

  /* ── sound ───────────────────────────────────────────── */
  function playSound() {
    try {
      if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      [880, 1100].forEach(function (freq, i) {
        var osc  = audioCtx.createOscillator();
        var gain = audioCtx.createGain();
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.frequency.value = freq;
        osc.type = 'sine';
        var t = audioCtx.currentTime + i * 0.18;
        gain.gain.setValueAtTime(0, t);
        gain.gain.linearRampToValueAtTime(0.28, t + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.5);
        osc.start(t);
        osc.stop(t + 0.5);
      });
    } catch (e) {}
  }

  /* ── render dropdown list ────────────────────────────── */
  function renderList(items) {
    var list = $('notifList');
    if (!list) return;
    if (!items || !items.length) {
      list.innerHTML =
        '<div class="notif-empty">' +
          '<i class="fas fa-bell-slash"></i>' +
          '<p>No new notifications</p>' +
        '</div>';
      return;
    }
    list.innerHTML = items.map(function (n) {
      return (
        '<a class="notif-item" href="' + CTX + (n.link || '/') + '">' +
          '<div class="notif-icon">' + iconFor(n.type) + '</div>' +
          '<div class="notif-body">' +
            '<div class="notif-msg">' + n.message + '</div>' +
            '<div class="notif-time">' + timeAgo(n.time) + '</div>' +
          '</div>' +
        '</a>'
      );
    }).join('');
  }

  /* ── toast popup ──────────────────────────────────────── */
  function showToast(notif) {
    var old = $('notifToast');
    if (old) old.remove();

    var t = document.createElement('div');
    t.id        = 'notifToast';
    t.className = 'notif-toast';
    t.innerHTML =
      '<div class="toast-icon">' + (notif ? iconFor(notif.type) : '🔔') + '</div>' +
      '<div class="toast-body">' +
        '<strong>' + (notif && notif.type === 'MESSAGE' ? 'New message' : 'New notification') + '</strong>' +
        '<p>' + (notif ? notif.message : '') + '</p>' +
      '</div>' +
      '<button class="toast-close" onclick="this.parentElement.remove()">&#x2715;</button>';

    if (notif && notif.link) {
      t.style.cursor = 'pointer';
      t.addEventListener('click', function (e) {
        if (e.target.className === 'toast-close') return;
        window.location.href = CTX + notif.link;
      });
    }

    document.body.appendChild(t);
    requestAnimationFrame(function () {
      requestAnimationFrame(function () { t.classList.add('show'); });
    });
    setTimeout(function () {
      t.classList.remove('show');
      setTimeout(function () { if (t.parentNode) t.remove(); }, 400);
    }, 5000);
  }

  /* ── mark all read (exposed to header inline script) ─── */
  window._markAllRead = function () {
    fetch(CTX + '/notifications?action=markRead', { credentials: 'same-origin' })
      .then(function () {
        prevCount = 0;
        showBadge($('notifBadge'), 0);
      })
      .catch(function () {});
  };

  /* ── poll ─────────────────────────────────────────────── */
  function poll() {
    fetch(CTX + '/notifications', { credentials: 'same-origin' })
      .then(function (r) {
        if (!r.ok) throw new Error('HTTP ' + r.status);
        return r.json();
      })
      .then(function (data) {
        var notifCount = data.count     || 0;
        var chatCount  = data.chatCount || 0;

        /* Play sound + toast only when NEW notifications arrive (not first load) */
        if (prevCount >= 0 && notifCount > prevCount) {
          playSound();
          showToast(data.items && data.items[0] ? data.items[0] : null);
        }
        prevCount = notifCount;

        /* Update bell badge */
        showBadge($('notifBadge'), notifCount);

        /* Tint bell red when there are unread notifications */
        var bellBtn = $('notifBellBtn');
        if (bellBtn) bellBtn.style.color = notifCount > 0 ? '#e74c3c' : '';

        /* Update chat badge */
        showBadge($('chatBadge'), chatCount);

        /* Update mobile bottom nav badges */
        showBadge($('mobBotChatBadge'),  chatCount);
        showBadge($('mobBotNotifBadge'), notifCount);
        showBadge($('mobChatBadge'),     chatCount);
        showBadge($('mobNotifBadge'),    notifCount);

        /* Sync mobile notification list with desktop list */
        var mobList = $('mobNotifList');
        if (mobList) mobList.innerHTML = $('notifList') ? $('notifList').innerHTML : '';

        /* Render dropdown items */
        renderList(data.items);
      })
      .catch(function (err) {
        console.warn('IDUKA notifications poll error:', err);
      });
  }

  /* Start */
  poll();
  setInterval(poll, 5000);   // every 5 seconds like Facebook

})();
