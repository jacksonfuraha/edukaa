const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const pool = require('../database/connection');
const router = express.Router();

// Register user
router.post('/register', [
  body('username').isLength({ min: 3 }).withMessage('Username must be at least 3 characters'),
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('full_name').notEmpty().withMessage('Full name is required'),
  body('phone').notEmpty().withMessage('Phone number is required'),
  body('user_type').isIn(['buyer', 'seller']).withMessage('User type must be buyer or seller'),
  body('address').isObject().withMessage('Address information is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { username, email, password, full_name, phone, user_type, address } = req.body;

    // Check if user already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1 OR username = $2',
      [email, username]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'User with this email or username already exists'
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(12);
    const password_hash = await bcrypt.hash(password, salt);

    // Start transaction
    await pool.query('BEGIN');

    // Create user
    const newUser = await pool.query(
      `INSERT INTO users (username, email, password_hash, full_name, phone, user_type)
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, username, email, full_name, phone, user_type`,
      [username, email, password_hash, full_name, phone, user_type]
    );

    const userId = newUser.rows[0].id;

    // Create address
    await pool.query(
      `INSERT INTO addresses (user_id, country, province, district, sector, cell, village, street_address, is_default)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        userId,
        address.country || 'Rwanda',
        address.province,
        address.district,
        address.sector,
        address.cell,
        address.village,
        address.street_address,
        true
      ]
    );

    await pool.query('COMMIT');

    // Generate JWT token
    const token = jwt.sign(
      { userId: userId, userType: user_type },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: {
          id: userId,
          username: newUser.rows[0].username,
          email: newUser.rows[0].email,
          full_name: newUser.rows[0].full_name,
          phone: newUser.rows[0].phone,
          user_type: newUser.rows[0].user_type
        },
        token
      }
    });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during registration'
    });
  }
});

// Login user
router.post('/login', [
  body('email').isEmail().withMessage('Please provide a valid email'),
  body('password').notEmpty().withMessage('Password is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email, password } = req.body;

    // Find user
    const user = await pool.query(
      'SELECT id, username, email, password_hash, full_name, phone, user_type, is_verified FROM users WHERE email = $1',
      [email]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.rows[0].password_hash);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.rows[0].id, userType: user.rows[0].user_type },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.rows[0].id,
          username: user.rows[0].username,
          email: user.rows[0].email,
          full_name: user.rows[0].full_name,
          phone: user.rows[0].phone,
          user_type: user.rows[0].user_type,
          is_verified: user.rows[0].is_verified
        },
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
});

// Verify token
router.get('/verify', async (req, res) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await pool.query(
      'SELECT id, username, email, full_name, phone, user_type, is_verified FROM users WHERE id = $1',
      [decoded.userId]
    );

    if (user.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    res.json({
      success: true,
      data: {
        user: user.rows[0]
      }
    });
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }
});

module.exports = router;
