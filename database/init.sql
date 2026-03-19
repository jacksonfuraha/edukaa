-- IDUKA Database - Auto-initialization for Railway
-- This runs automatically when Railway MySQL starts

CREATE DATABASE IF NOT EXISTS iduka_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE iduka_db;

CREATE TABLE IF NOT EXISTS users (
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

CREATE TABLE IF NOT EXISTS categories (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    icon_class VARCHAR(80) DEFAULT 'fas fa-tag'
);

CREATE TABLE IF NOT EXISTS products (
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
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product_videos (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    seller_id     INT NOT NULL,
    product_id    INT,
    title         VARCHAR(200),
    video_url     VARCHAR(255) NOT NULL,
    thumbnail_url VARCHAR(255),
    likes         INT DEFAULT 0,
    active        BOOLEAN DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS video_likes (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    video_id   INT NOT NULL,
    user_id    INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (video_id, user_id)
);

CREATE TABLE IF NOT EXISTS video_comments (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    video_id   INT NOT NULL,
    user_id    INT NOT NULL,
    comment    TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
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

CREATE TABLE IF NOT EXISTS chat_messages (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT NOT NULL,
    receiver_id INT NOT NULL,
    product_id  INT DEFAULT 0,
    message     TEXT NOT NULL,
    sent_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id)   REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id)
);

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

-- Default categories
INSERT IGNORE INTO categories (id, name, icon_class) VALUES
(1,  'Electronics',     'fas fa-laptop'),
(2,  'Fashion',         'fas fa-tshirt'),
(3,  'Food & Drinks',   'fas fa-utensils'),
(4,  'Home & Garden',   'fas fa-home'),
(5,  'Health & Beauty', 'fas fa-spa'),
(6,  'Agriculture',     'fas fa-seedling'),
(7,  'Services',        'fas fa-tools'),
(8,  'Vehicles',        'fas fa-car'),
(9,  'Education',       'fas fa-book'),
(10, 'Other',           'fas fa-box');

SELECT 'IDUKA database ready!' AS status;
