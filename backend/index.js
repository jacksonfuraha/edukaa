const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

dotenv.config();
const prisma = new PrismaClient();
const app = express();
const PORT = process.env.PORT || 4000;
const JWT_SECRET = process.env.JWT_SECRET || 'iduka_secret';

app.use(cors({ origin: 'http://localhost:5173' }));
app.use(express.json());

function generateToken(user) {
  return jwt.sign({ id: user.id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
}

async function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authorization required' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

app.post('/api/auth/signup', async (req, res) => {
  const {
    email,
    password,
    fullName,
    phone,
    role,
    country,
    province,
    district,
    sector,
    cell,
    village,
    idCardNumber,
    tinNumber
  } = req.body;

  if (!email || !password || !fullName || !phone || !role || !country || !province || !district || !sector || !cell || !village) {
    return res.status(400).json({ error: 'All required fields must be filled.' });
  }

  if (role === 'SELLER' && (!idCardNumber || !tinNumber)) {
    return res.status(400).json({ error: 'Sellers must provide ID card and TIN numbers for verification.' });
  }

  try {
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(400).json({ error: 'Email already in use.' });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        fullName,
        phone,
        role,
        country,
        province,
        district,
        sector,
        cell,
        village,
        idCardNumber: role === 'SELLER' ? idCardNumber : null,
        tinNumber: role === 'SELLER' ? tinNumber : null,
        isVerified: role === 'SELLER' ? false : true
      }
    });
    const token = generateToken(user);
    res.json({ user: { id: user.id, email: user.email, role: user.role, fullName: user.fullName }, token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Signup failed' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required.' });
  }
  try {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid credentials.' });
    }
    const token = generateToken(user);
    res.json({ user: { id: user.id, email: user.email, role: user.role, fullName: user.fullName, isVerified: user.isVerified }, token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Login failed' });
  }
});

app.get('/api/products', async (req, res) => {
  try {
    const products = await prisma.product.findMany({
      where: { available: true },
      include: { seller: { select: { fullName: true, role: true } } },
      orderBy: { createdAt: 'desc' }
    });
    res.json({ products });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to load products' });
  }
});

app.post('/api/products', authMiddleware, async (req, res) => {
  const { title, description, price, imageUrl, videoUrl, category } = req.body;
  if (!title || !description || !price) {
    return res.status(400).json({ error: 'Title, description, and price are required.' });
  }
  try {
    const product = await prisma.product.create({
      data: {
        title,
        description,
        price: parseFloat(price),
        imageUrl,
        videoUrl,
        category,
        seller: { connect: { id: req.user.id } }
      }
    });
    res.json({ product });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Product creation failed' });
  }
});

app.get('/api/videos', async (req, res) => {
  try {
    const videos = await prisma.product.findMany({
      where: { videoUrl: { not: null } },
      select: { id: true, title: true, description: true, videoUrl: true, price: true, createdAt: true }
    });
    res.json({ videos });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to load videos' });
  }
});

app.get('/api/chat/:userId', authMiddleware, async (req, res) => {
  const otherUserId = parseInt(req.params.userId, 10);
  if (!otherUserId) {
    return res.status(400).json({ error: 'Invalid user id.' });
  }
  try {
    const messages = await prisma.message.findMany({
      where: {
        OR: [
          { senderId: req.user.id, receiverId: otherUserId },
          { senderId: otherUserId, receiverId: req.user.id }
        ]
      },
      orderBy: { createdAt: 'asc' }
    });
    res.json({ messages });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to load chat messages.' });
  }
});

app.post('/api/chat', authMiddleware, async (req, res) => {
  const { receiverId, content, productId } = req.body;
  if (!receiverId || !content) {
    return res.status(400).json({ error: 'Receiver and content are required.' });
  }
  try {
    const message = await prisma.message.create({
      data: {
        sender: { connect: { id: req.user.id } },
        receiver: { connect: { id: parseInt(receiverId, 10) } },
        content,
        product: productId ? { connect: { id: parseInt(productId, 10) } } : undefined
      }
    });
    res.json({ message });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to send message.' });
  }
});

app.get('/api/profile', authMiddleware, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: { id: true, email: true, role: true, fullName: true, phone: true, country: true, province: true, district: true, sector: true, cell: true, village: true, isVerified: true }
    });
    res.json({ user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to load profile.' });
  }
});

app.listen(PORT, () => {
  console.log(`Backend listening on http://localhost:${PORT}`);
});
