-- ============================================
-- IDUKA Database Schema
-- Run this script in MySQL before starting
-- ============================================

CREATE DATABASE IF NOT EXISTS iduka_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE iduka_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role ENUM('BUYER','SELLER') NOT NULL,
    country VARCHAR(60) DEFAULT 'Rwanda',
    province VARCHAR(60),
    district VARCHAR(60),
    sector VARCHAR(60),
    cell VARCHAR(60),
    village VARCHAR(60),
    avatar_url VARCHAR(255) DEFAULT 'images/default-avatar.png',
    active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    icon_class VARCHAR(60) DEFAULT 'fas fa-tag'
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    image_url VARCHAR(255) DEFAULT 'images/default-product.png',
    active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    delivery_address TEXT,
    status ENUM('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Chat Messages table
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    product_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (receiver_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Product Videos table (TikTok-style)
CREATE TABLE IF NOT EXISTS product_videos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    product_id INT NOT NULL,
    title VARCHAR(200),
    video_url VARCHAR(255) NOT NULL,
    thumbnail_url VARCHAR(255),
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Seed categories
INSERT INTO categories (name, icon_class) VALUES
('Electronics', 'fas fa-laptop'),
('Fashion & Clothing', 'fas fa-tshirt'),
('Food & Groceries', 'fas fa-apple-alt'),
('Home & Furniture', 'fas fa-couch'),
('Beauty & Health', 'fas fa-spa'),
('Agriculture', 'fas fa-seedling'),
('Books & Education', 'fas fa-book'),
('Sports & Fitness', 'fas fa-running'),
('Arts & Crafts', 'fas fa-paint-brush'),
('Services', 'fas fa-concierge-bell');

-- Sample admin/seller user (password: admin123)
INSERT INTO users (full_name, email, phone, password, role, country, province, district, sector, cell, village)
VALUES ('IDUKA Admin', 'admin@iduka.rw', '+250780000000',
'$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMqJqhN8/LewdBPj4oQkqq0rXC',
'SELLER','Rwanda','Kigali','Gasabo','Remera','Nyarutarama','Nyarutarama Village');

SELECT 'Database setup complete!' AS status;
