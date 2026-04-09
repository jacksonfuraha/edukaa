const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function setupDatabase() {
  try {
    console.log('Setting up database...');

    // Create database if it doesn't exist
    await pool.query(`CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME}`);
    
    // Connect to the database
    const db = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    });

    // Create tables
    await db.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(100) NOT NULL,
        phone VARCHAR(20) NOT NULL,
        user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('buyer', 'seller')),
        profile_image TEXT,
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS addresses (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        country VARCHAR(50) NOT NULL DEFAULT 'Rwanda',
        province VARCHAR(50) NOT NULL,
        district VARCHAR(50) NOT NULL,
        sector VARCHAR(50) NOT NULL,
        cell VARCHAR(50) NOT NULL,
        village VARCHAR(50) NOT NULL,
        street_address TEXT,
        is_default BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(200) NOT NULL,
        description TEXT NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        category VARCHAR(50) NOT NULL,
        condition VARCHAR(20) NOT NULL CHECK (condition IN ('new', 'used', 'refurbished')),
        stock_quantity INTEGER NOT NULL DEFAULT 1,
        images TEXT[],
        video_url TEXT,
        is_active BOOLEAN DEFAULT TRUE,
        is_featured BOOLEAN DEFAULT FALSE,
        views INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS product_videos (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        video_url TEXT NOT NULL,
        thumbnail TEXT,
        duration INTEGER,
        caption TEXT,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS chats (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
        seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        last_message TEXT,
        last_message_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS chat_messages (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
        sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
        message TEXT NOT NULL,
        message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
        file_url TEXT,
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
        seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        quantity INTEGER NOT NULL,
        total_price DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
        payment_method VARCHAR(20) NOT NULL,
        payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
        shipping_address TEXT,
        tracking_number TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        buyer_id UUID REFERENCES users(id) ON DELETE CASCADE,
        seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        review_text TEXT,
        is_verified_purchase BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      CREATE TABLE IF NOT EXISTS favorites (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, product_id)
      );
    `);

    // Create indexes for better performance
    await db.query('CREATE INDEX IF NOT EXISTS idx_products_seller ON products(seller_id);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_chats_buyer ON chats(buyer_id);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_chats_seller ON chats(seller_id);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_chat_messages_chat ON chat_messages(chat_id);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_orders_buyer ON orders(buyer_id);');
    await db.query('CREATE INDEX IF NOT EXISTS idx_orders_seller ON orders(seller_id);');

    console.log('Database setup completed successfully!');
    await db.end();
    await pool.end();
  } catch (error) {
    console.error('Database setup failed:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  setupDatabase();
}

module.exports = setupDatabase;
