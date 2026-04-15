-- ============================================================
-- IDUKA - Complete Migration Script
-- Run this on your EXISTING database to add all missing columns
-- Safe to run multiple times (uses IF NOT EXISTS / IF EXISTS)
-- ============================================================
USE iduka_db;

-- ─── USERS TABLE ──────────────────────────────────────────────────────────
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url  VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_number   VARCHAR(30);
ALTER TABLE users ADD COLUMN IF NOT EXISTS tin_number  VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_card_url VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS verified    BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS active      BOOLEAN DEFAULT TRUE;
-- If old schema used 'password_hash', rename it
SET @col_exists = (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='password_hash'
);
SET @sql = IF(@col_exists > 0,
  'ALTER TABLE users CHANGE COLUMN password_hash password VARCHAR(255) NOT NULL',
  'SELECT "password column OK" AS msg'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- If old schema used 'is_active', add 'active' as alias
ALTER TABLE users ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE;

-- ─── CATEGORIES TABLE ─────────────────────────────────────────────────────
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon_class VARCHAR(80) DEFAULT 'fas fa-tag';
-- Copy old 'icon' column data to 'icon_class' if it existed
SET @has_icon = (
  SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='categories' AND COLUMN_NAME='icon'
);
SET @sql2 = IF(@has_icon > 0,
  'UPDATE categories SET icon_class = CONCAT(\'fas \', icon) WHERE icon IS NOT NULL AND (icon_class IS NULL OR icon_class = \'fas fa-tag\')',
  'SELECT "icon_class OK" AS msg'
);
PREPARE stmt FROM @sql2; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ─── PRODUCTS TABLE ────────────────────────────────────────────────────────
-- Add 'active' if missing (old schema may have 'is_active')
ALTER TABLE products ADD COLUMN IF NOT EXISTS active    BOOLEAN DEFAULT TRUE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url VARCHAR(255);
ALTER TABLE products ADD COLUMN IF NOT EXISTS stock     INT DEFAULT 0;

-- Copy old column data if present
SET @has_image1 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='products' AND COLUMN_NAME='image1');
SET @sql3 = IF(@has_image1 > 0,
  'UPDATE products SET image_url = image1 WHERE image_url IS NULL AND image1 IS NOT NULL',
  'SELECT "image_url OK" AS msg');
PREPARE stmt FROM @sql3; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @has_sq = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='products' AND COLUMN_NAME='stock_quantity');
SET @sql4 = IF(@has_sq > 0,
  'UPDATE products SET stock = stock_quantity WHERE stock = 0 AND stock_quantity > 0',
  'SELECT "stock OK" AS msg');
PREPARE stmt FROM @sql4; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ─── PRODUCT_VIDEOS TABLE ──────────────────────────────────────────────────
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS video_url     VARCHAR(255);
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(255);
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS likes         INT DEFAULT 0;
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS active        BOOLEAN DEFAULT TRUE;

-- Copy old video_path data to video_url
SET @has_vp = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='product_videos' AND COLUMN_NAME='video_path');
SET @sql5 = IF(@has_vp > 0,
  'UPDATE product_videos SET video_url = video_path WHERE video_url IS NULL AND video_path IS NOT NULL',
  'SELECT "video_url OK" AS msg');
PREPARE stmt FROM @sql5; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ─── ORDERS TABLE ─────────────────────────────────────────────────────────
ALTER TABLE orders ADD COLUMN IF NOT EXISTS unit_price     DECIMAL(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status ENUM('UNPAID','PAID','REFUNDED') DEFAULT 'UNPAID';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(100) DEFAULT 'Mobile Money';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_ref    VARCHAR(100);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payslip_sent   BOOLEAN DEFAULT FALSE;

-- ─── NOTIFICATIONS TABLE (NEW) ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    type       VARCHAR(30) NOT NULL,
    message    TEXT NOT NULL,
    link       VARCHAR(255) DEFAULT '',
    is_read    BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

SELECT 'Migration complete! All columns and tables are up to date.' AS status;

-- VIDEO LIKES table
CREATE TABLE IF NOT EXISTS video_likes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    video_id   INT NOT NULL,
    user_id    INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (video_id, user_id),
    FOREIGN KEY (video_id) REFERENCES product_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)  REFERENCES users(id) ON DELETE CASCADE
);

-- VIDEO COMMENTS table
CREATE TABLE IF NOT EXISTS video_comments (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    video_id   INT NOT NULL,
    user_id    INT NOT NULL,
    comment    TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (video_id) REFERENCES product_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)  REFERENCES users(id) ON DELETE CASCADE
);

SELECT 'All tables ready!' AS status;
