/**
 * IDUKA Media URL Fixer
 * Fixes all img[data-stored] and video[data-stored] src attributes.
 * DB stores "products/uuid.jpg" or "videos/uuid.mp4"
 * Served at:  /IDUKA/uploads/products/uuid.jpg
 */
(function() {
    var ctx = window.IDUKA_CTX || '';

    function buildUrl(stored) {
        if (!stored || stored === '' ||
            stored.startsWith('default-') ||
            stored.startsWith('images/')) {
            return ctx + '/images/default-product.svg';
        }
        // Already a full path stored the old way
        if (stored.startsWith('uploads/')) return ctx + '/' + stored;
        // New way: "products/uuid.jpg" or "videos/uuid.mp4"
        return ctx + '/uploads/' + stored;
    }

    // Fix all images with data-stored attribute
    document.querySelectorAll('img[data-stored]').forEach(function(img) {
        var stored = img.getAttribute('data-stored');
        img.src = buildUrl(stored);
        img.onerror = function() {
            this.onerror = null;
            this.src = ctx + '/images/default-product.svg';
        };
    });

    // Fix all videos with data-stored attribute
    document.querySelectorAll('video[data-stored]').forEach(function(vid) {
        var stored = vid.getAttribute('data-stored');
        if (stored) {
            vid.src = buildUrl(stored);
        }
    });
})();
