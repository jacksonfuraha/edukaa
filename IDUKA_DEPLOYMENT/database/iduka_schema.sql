-- ============================================================
-- IDUKA - Rwanda Online Marketplace
-- Full Schema v3 - includes notifications + seller verification
-- ============================================================
DROP DATABASE IF EXISTS iduka_db;
CREATE DATABASE iduka_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE iduka_db;

CREATE TABLE users (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(100) UNIQUE NOT NULL,
    phone        VARCHAR(20),
    password     VARCHAR(255) NOT NULL,
    role         ENUM('BUYER','SELLER','ADMIN') DEFAULT 'BUYER',
    country      VARCHAR(100) DEFAULT 'Rwanda',
    province     VARCHAR(100),
    district     VARCHAR(100),
    sector       VARCHAR(100),
    cell         VARCHAR(100),
    village      VARCHAR(100),
    avatar_url   VARCHAR(255),
    id_number    VARCHAR(30),
    tin_number   VARCHAR(20),
    id_card_url  VARCHAR(255),
    verified     BOOLEAN DEFAULT FALSE,
    active       BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    icon_class VARCHAR(80)  DEFAULT 'fas fa-tag'
);

CREATE TABLE products (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    seller_id   INT NOT NULL,
    category_id INT,
    name        VARCHAR(200) NOT NULL,
    description TEXT,
    price       DECIMAL(10,2) NOT NULL,
    stock       INT DEFAULT 0,
    image_url   VARCHAR(255),
    active      BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id)   REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE product_videos (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    seller_id     INT NOT NULL,
    product_id    INT,
    title         VARCHAR(200),
    video_url     VARCHAR(255) NOT NULL,
    thumbnail_url VARCHAR(255),
    likes         INT DEFAULT 0,
    active        BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id)  REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

CREATE TABLE orders (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id         INT NOT NULL,
    product_id       INT NOT NULL,
    quantity         INT DEFAULT 1,
    unit_price       DECIMAL(10,2),
    total_price      DECIMAL(10,2) NOT NULL,
    delivery_address TEXT,
    status           ENUM('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED') DEFAULT 'PENDING',
    payment_status   ENUM('UNPAID','PAID','REFUNDED') DEFAULT 'UNPAID',
    payment_method   VARCHAR(100) DEFAULT 'Mobile Money',
    payment_ref      VARCHAR(100),
    payslip_sent     BOOLEAN DEFAULT FALSE,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id)   REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE chat_messages (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT NOT NULL,
    receiver_id INT NOT NULL,
    product_id  INT DEFAULT 0,
    message     TEXT NOT NULL,
    sent_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id)   REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id)
);

-- NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    type       VARCHAR(30) NOT NULL,   -- ORDER, ORDER_STATUS, MESSAGE, LIKE
    message    TEXT NOT NULL,
    link       VARCHAR(255) DEFAULT '',
    is_read    BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Seed categories
INSERT INTO categories (name, icon_class) VALUES
('Agriculture',        'fas fa-seedling'),
('Arts & Crafts',      'fas fa-paint-brush'),
('Beauty & Health',    'fas fa-spa'),
('Books & Education',  'fas fa-book'),
('Electronics',        'fas fa-laptop'),
('Fashion & Clothing', 'fas fa-tshirt'),
('Food & Groceries',   'fas fa-apple-alt'),
('Home & Furniture',   'fas fa-couch'),
('Services',           'fas fa-hands-helping'),
('Sports & Fitness',   'fas fa-running');

-- Default admin (password: Admin@123)
INSERT INTO users (full_name,email,phone,password,role,country,province,district,sector,cell,village,verified)
VALUES ('IDUKA Admin','admin@iduka.rw','+250788000000',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewEIECq5fGqE5G1i',
        'ADMIN','Rwanda','Eastern Province','Nyagatare','Karangazi','Rwisirabo','Rubona',TRUE);

SELECT 'Database ready!' AS status;

-- VIDEO LIKES (track who liked what - prevent double-liking)
CREATE TABLE IF NOT EXISTS video_likes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    video_id   INT NOT NULL,
    user_id    INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (video_id, user_id),
    FOREIGN KEY (video_id) REFERENCES product_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)  REFERENCES users(id) ON DELETE CASCADE
);

-- VIDEO COMMENTS
CREATE TABLE IF NOT EXISTS video_comments (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    video_id   INT NOT NULL,
    user_id    INT NOT NULL,
    comment    TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (video_id) REFERENCES product_videos(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)  REFERENCES users(id) ON DELETE CASCADE
);
