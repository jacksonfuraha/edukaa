-- ============================================================
-- IDUKA Migration Script
-- Run this ONLY if you already have data and don't want to 
-- lose it. Otherwise use iduka_schema.sql (fresh install).
-- ============================================================
USE iduka_db;

-- 1. Fix users table column names
ALTER TABLE users 
  CHANGE COLUMN password_hash password   VARCHAR(255) NOT NULL,
  CHANGE COLUMN is_active     active     BOOLEAN DEFAULT TRUE,
  CHANGE COLUMN cell_area     cell       VARCHAR(100);

-- (these lines are safe to ignore if columns already have the right names)

-- 2. Add missing columns to users
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(255);

-- 3. Fix categories table - add icon_class column
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon_class VARCHAR(80) DEFAULT 'fas fa-tag';
UPDATE categories SET icon_class = CONCAT('fas ', icon) WHERE icon IS NOT NULL AND icon_class IS NULL;

-- 4. Fix orders table - remove seller_id dependency, add payment columns
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status  ENUM('UNPAID','PAID','REFUNDED') DEFAULT 'UNPAID';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method  VARCHAR(100) DEFAULT 'Mobile Money';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_ref     VARCHAR(100);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payslip_sent    BOOLEAN DEFAULT FALSE;

-- 5. Fix products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url   VARCHAR(255);
ALTER TABLE products ADD COLUMN IF NOT EXISTS active      BOOLEAN DEFAULT TRUE;

-- Update image_url from old image1 if needed
UPDATE products SET image_url = image1 WHERE image_url IS NULL AND image1 IS NOT NULL;

-- 6. Fix product_videos table
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS video_url     VARCHAR(255);
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(255);
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS likes         INT DEFAULT 0;
ALTER TABLE product_videos ADD COLUMN IF NOT EXISTS active        BOOLEAN DEFAULT TRUE;

UPDATE product_videos SET video_url = video_path WHERE video_url IS NULL AND video_path IS NOT NULL;

SELECT 'Migration complete!' AS status;
