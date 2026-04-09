const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'client', 'build')));

// File paths
const DATA_DIR = path.join(__dirname, 'data');
const USERS_FILE = path.join(DATA_DIR, 'users.json');
const PRODUCTS_FILE = path.join(DATA_DIR, 'products.json');
const CHATS_FILE = path.join(DATA_DIR, 'chats.json');
const ORDERS_FILE = path.join(DATA_DIR, 'orders.json');
const VIDEOS_FILE = path.join(DATA_DIR, 'videos.json');

// Ensure data directory exists
if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
}

// Initialize data files if they don't exist
const initializeFile = (filePath, defaultData = []) => {
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, JSON.stringify(defaultData, null, 2));
  }
};

initializeFile(USERS_FILE);
initializeFile(PRODUCTS_FILE);
initializeFile(CHATS_FILE);
initializeFile(ORDERS_FILE);
initializeFile(VIDEOS_FILE);

// Helper functions
const readData = (filePath) => {
  try {
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`Error reading ${filePath}:`, error);
    return [];
  }
};

const writeData = (filePath, data) => {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
  } catch (error) {
    console.error(`Error writing ${filePath}:`, error);
  }
};

// Auth Routes
app.post('/api/auth/register', (req, res) => {
  const { username, email, password, full_name, phone, user_type } = req.body;
  
  const users = readData(USERS_FILE);
  
  // Check if user already exists
  if (users.find(u => u.email === email)) {
    return res.status(400).json({ message: 'User already exists' });
  }
  
  const newUser = {
    id: uuidv4(),
    username,
    email,
    password, // In production, hash this
    full_name,
    phone,
    user_type,
    created_at: new Date().toISOString(),
    is_verified: false
  };
  
  users.push(newUser);
  writeData(USERS_FILE, users);
  
  res.status(201).json({ 
    message: 'User registered successfully',
    user: { id: newUser.id, username, email, full_name, user_type }
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  const users = readData(USERS_FILE);
  const user = users.find(u => u.email === email && u.password === password);
  
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  
  res.json({ 
    message: 'Login successful',
    user: { id: user.id, username, email, full_name, user_type },
    token: 'mock-jwt-token' // In production, use real JWT
  });
});

// Products Routes
app.get('/api/products', (req, res) => {
  const { search, category, min_price, max_price, sort } = req.query;
  let products = readData(PRODUCTS_FILE);
  
  // Apply filters
  if (search) {
    products = products.filter(p => 
      p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.description.toLowerCase().includes(search.toLowerCase())
    );
  }
  
  if (category) {
    products = products.filter(p => p.category === category);
  }
  
  if (min_price) {
    products = products.filter(p => p.price >= parseFloat(min_price));
  }
  
  if (max_price) {
    products = products.filter(p => p.price <= parseFloat(max_price));
  }
  
  // Apply sorting
  if (sort === 'price') {
    products.sort((a, b) => a.price - b.price);
  } else {
    products.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }
  
  res.json({ products });
});

app.get('/api/products/:id', (req, res) => {
  const products = readData(PRODUCTS_FILE);
  const product = products.find(p => p.id === req.params.id);
  
  if (!product) {
    return res.status(404).json({ message: 'Product not found' });
  }
  
  res.json({ product });
});

app.post('/api/products', (req, res) => {
  const { title, description, price, category, condition, stock_quantity, seller_id } = req.body;
  
  const products = readData(PRODUCTS_FILE);
  
  const newProduct = {
    id: uuidv4(),
    title,
    description,
    price: parseFloat(price),
    category,
    condition,
    stock_quantity: parseInt(stock_quantity),
    seller_id,
    images: [],
    is_active: true,
    views: 0,
    created_at: new Date().toISOString()
  };
  
  products.push(newProduct);
  writeData(PRODUCTS_FILE, products);
  
  res.status(201).json({ product: newProduct });
});

// Chat Routes
app.get('/api/chat', (req, res) => {
  const { user_id } = req.query;
  const chats = readData(CHATS_FILE);
  const userChats = chats.filter(c => c.buyer_id === user_id || c.seller_id === user_id);
  res.json({ chats: userChats });
});

app.post('/api/chat', (req, res) => {
  const { buyer_id, seller_id, product_id } = req.body;
  
  const chats = readData(CHATS_FILE);
  
  const newChat = {
    id: uuidv4(),
    buyer_id,
    seller_id,
    product_id,
    messages: [],
    created_at: new Date().toISOString(),
    is_active: true
  };
  
  chats.push(newChat);
  writeData(CHATS_FILE, chats);
  
  res.status(201).json({ chat: newChat });
});

// Video Routes
app.get('/api/videos/feed', (req, res) => {
  const { category, page = 1, limit = 10 } = req.query;
  let videos = readData(VIDEOS_FILE);
  
  if (category) {
    videos = videos.filter(v => v.category === category);
  }
  
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedVideos = videos.slice(startIndex, endIndex);
  
  res.json({ 
    videos: paginatedVideos,
    hasMore: endIndex < videos.length
  });
});

// Orders Routes
app.post('/api/orders', (req, res) => {
  const { buyer_id, seller_id, product_id, quantity, total_price, shipping_address } = req.body;
  
  const orders = readData(ORDERS_FILE);
  
  const newOrder = {
    id: uuidv4(),
    buyer_id,
    seller_id,
    product_id,
    quantity: parseInt(quantity),
    total_price: parseFloat(total_price),
    shipping_address,
    status: 'pending',
    payment_status: 'pending',
    created_at: new Date().toISOString()
  };
  
  orders.push(newOrder);
  writeData(ORDERS_FILE, orders);
  
  res.status(201).json({ order: newOrder });
});

// Mock payment routes
app.post('/api/payments/momo/initiate', (req, res) => {
  res.json({ 
    message: 'Payment initiated',
    reference: 'MOCK-' + uuidv4(),
    status: 'pending'
  });
});

app.post('/api/payments/airtel/initiate', (req, res) => {
  res.json({ 
    message: 'Payment initiated',
    reference: 'MOCK-' + uuidv4(),
    status: 'pending'
  });
});

// Serve React app
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'client', 'build', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
