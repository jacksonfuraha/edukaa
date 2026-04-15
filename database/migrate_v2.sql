-- ============================================================
-- IDUKA Migration Script v2
-- Run this if you already have the database set up
-- It safely adds missing columns without dropping existing data
-- ============================================================
USE iduka_db;

-- Add seller_id to orders (get from products via product_id)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS seller_id INT AFTER buyer_id;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS unit_price DECIMAL(10,2) AFTER quantity;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status ENUM('UNPAID','PAID','REFUNDED') DEFAULT 'UNPAID';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(100) DEFAULT 'Mobile Money';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_ref VARCHAR(100);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payslip_sent BOOLEAN DEFAULT FALSE;

-- Fix seller_id for existing orders using product's seller
UPDATE orders o JOIN products p ON o.product_id = p.id SET o.seller_id = p.seller_id WHERE o.seller_id IS NULL;

-- Fix unit_price for existing orders
UPDATE orders o JOIN products p ON o.product_id = p.id SET o.unit_price = p.price WHERE o.unit_price IS NULL;

-- Add avatar_url to users if missing
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(255);

-- Add icon_class to categories if missing  
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon_class VARCHAR(80) DEFAULT 'fas fa-tag';

-- Update category icons if they exist but have wrong column name
UPDATE categories SET icon_class = 'fas fa-seedling'     WHERE name = 'Agriculture'        AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-paint-brush'  WHERE name = 'Arts & Crafts'      AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-spa'          WHERE name = 'Beauty & Health'     AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-book'         WHERE name = 'Books & Education'   AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-laptop'       WHERE name = 'Electronics'         AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-tshirt'       WHERE name = 'Fashion & Clothing'  AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-apple-alt'    WHERE name = 'Food & Groceries'    AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-couch'        WHERE name = 'Home & Furniture'    AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-hands-helping' WHERE name = 'Services'           AND icon_class IS NULL;
UPDATE categories SET icon_class = 'fas fa-running'      WHERE name = 'Sports & Fitness'    AND icon_class IS NULL;

SELECT 'Migration complete!' as status;
