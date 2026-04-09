(function() {
    var ctx = window.IDUKA_CTX || '';
    var items = document.querySelectorAll('.video-item');
    var currentVideo = null;

    // IntersectionObserver: auto-play when 70% visible
    if ('IntersectionObserver' in window) {
        var obs = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                var vid = entry.target.querySelector('.video-player');
                var btn = entry.target.querySelector('.play-btn i');
                if (!vid) return;
                if (entry.isIntersecting) {
                    if (currentVideo && currentVideo !== vid) {
                        currentVideo.pause();
                        currentVideo.currentTime = 0;
                        var prevBtn = currentVideo.closest('.video-item');
                        if (prevBtn) {
                            var prevIcon = prevBtn.querySelector('.play-btn i');
                            if (prevIcon) prevIcon.className = 'fas fa-play';
                        }
                    }
                    vid.play().then(function() {
                        if (btn) btn.className = 'fas fa-pause';
                        currentVideo = vid;
                    }).catch(function() {
                        if (btn) btn.className = 'fas fa-play';
                    });
                } else {
                    vid.pause();
                    if (btn) btn.className = 'fas fa-play';
                }
            });
        }, { threshold: 0.7 });
        items.forEach(function(item) { obs.observe(item); });
    }

    // Click overlay to play/pause
    items.forEach(function(item) {
        item.addEventListener('click', function(e) {
            if (e.target.closest('.video-actions') ||
                e.target.closest('.video-info a') ||
                e.target.closest('.play-btn')) return;
            var btn = item.querySelector('.play-btn');
            if (btn) togglePlay(btn);
        });
    });

    // Expose togglePlay globally
    window.togglePlay = function(btn) {
        var item = btn.closest('.video-item');
        var vid = item ? item.querySelector('.video-player') : null;
        var icon = btn.querySelector('i');
        if (!vid) return;
        if (vid.paused) {
            vid.play().then(function() {
                if (icon) icon.className = 'fas fa-pause';
                currentVideo = vid;
            }).catch(function() {
                if (icon) icon.className = 'fas fa-play';
            });
        } else {
            vid.pause();
            if (icon) icon.className = 'fas fa-play';
        }
    };

    // Like button
    window.likeVideo = function(videoId, btn) {
        btn.classList.toggle('liked');
        var span = btn.querySelector('span');
        var current = parseInt(span ? span.textContent : '0') || 0;
        if (span) span.textContent = btn.classList.contains('liked') ? current + 1 : Math.max(0, current - 1);
        fetch(ctx + '/videos?like=' + videoId, { method: 'POST' }).catch(function() {});
    };
})();
