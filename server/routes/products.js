const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../database/connection');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all products with filters
router.get('/', async (req, res) => {
  try {
    const { category, min_price, max_price, condition, search, sort = 'created_at', order = 'DESC', page = 1, limit = 20 } = req.query;
    
    let query = `
      SELECT p.*, u.username as seller_name, u.full_name as seller_full_name,
             COALESCE(AVG(r.rating), 0) as average_rating,
             COUNT(r.id) as review_count
      FROM products p
      JOIN users u ON p.seller_id = u.id
      LEFT JOIN reviews r ON p.id = r.product_id
      WHERE p.is_active = true
    `;
    
    const params = [];
    let paramIndex = 1;

    if (category) {
      query += ` AND p.category = $${paramIndex}`;
      params.push(category);
      paramIndex++;
    }

    if (min_price) {
      query += ` AND p.price >= $${paramIndex}`;
      params.push(min_price);
      paramIndex++;
    }

    if (max_price) {
      query += ` AND p.price <= $${paramIndex}`;
      params.push(max_price);
      paramIndex++;
    }

    if (condition) {
      query += ` AND p.condition = $${paramIndex}`;
      params.push(condition);
      paramIndex++;
    }

    if (search) {
      query += ` AND (p.title ILIKE $${paramIndex} OR p.description ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ` GROUP BY p.id, u.username, u.full_name`;
    
    // Sorting
    const allowedSorts = ['created_at', 'price', 'title', 'views', 'average_rating'];
    const sortField = allowedSorts.includes(sort) ? sort : 'created_at';
    const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    query += ` ORDER BY p.${sortField} ${sortOrder}`;

    // Pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count for pagination
    let countQuery = `
      SELECT COUNT(DISTINCT p.id) as total
      FROM products p
      WHERE p.is_active = true
    `;
    
    const countParams = [];
    let countIndex = 1;

    if (category) {
      countQuery += ` AND p.category = $${countIndex}`;
      countParams.push(category);
      countIndex++;
    }

    if (min_price) {
      countQuery += ` AND p.price >= $${countIndex}`;
      countParams.push(min_price);
      countIndex++;
    }

    if (max_price) {
      countQuery += ` AND p.price <= $${countIndex}`;
      countParams.push(max_price);
      countIndex++;
    }

    if (condition) {
      countQuery += ` AND p.condition = $${countIndex}`;
      countParams.push(condition);
      countIndex++;
    }

    if (search) {
      countQuery += ` AND (p.title ILIKE $${countIndex} OR p.description ILIKE $${countIndex})`;
      countParams.push(`%${search}%`);
      countIndex++;
    }

    const countResult = await pool.query(countQuery, countParams);

    res.json({
      success: true,
      data: {
        products: result.rows,
        pagination: {
          current_page: parseInt(page),
          total_pages: Math.ceil(countResult.rows[0].total / limit),
          total_products: parseInt(countResult.rows[0].total),
          per_page: parseInt(limit)
        }
      }
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching products'
    });
  }
});

// Get single product
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const productQuery = `
      SELECT p.*, u.username as seller_name, u.full_name as seller_full_name, u.phone as seller_phone,
             COALESCE(AVG(r.rating), 0) as average_rating,
             COUNT(r.id) as review_count
      FROM products p
      JOIN users u ON p.seller_id = u.id
      LEFT JOIN reviews r ON p.id = r.product_id
      WHERE p.id = $1 AND p.is_active = true
      GROUP BY p.id, u.username, u.full_name, u.phone
    `;

    const productResult = await pool.query(productQuery, [id]);

    if (productResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Increment view count
    await pool.query('UPDATE products SET views = views + 1 WHERE id = $1', [id]);

    // Get product reviews
    const reviewsQuery = `
      SELECT r.*, u.username as reviewer_name
      FROM reviews r
      JOIN users u ON r.buyer_id = u.id
      WHERE r.product_id = $1
      ORDER BY r.created_at DESC
    `;

    const reviewsResult = await pool.query(reviewsQuery, [id]);

    // Get product videos
    const videosQuery = `
      SELECT * FROM product_videos
      WHERE product_id = $1 AND is_active = true
      ORDER BY created_at DESC
    `;

    const videosResult = await pool.query(videosQuery, [id]);

    res.json({
      success: true,
      data: {
        product: productResult.rows[0],
        reviews: reviewsResult.rows,
        videos: videosResult.rows
      }
    });
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching product'
    });
  }
});

// Create product (seller only)
router.post('/', auth, [
  body('title').notEmpty().withMessage('Title is required'),
  body('description').notEmpty().withMessage('Description is required'),
  body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('category').notEmpty().withMessage('Category is required'),
  body('condition').isIn(['new', 'used', 'refurbished']).withMessage('Invalid condition'),
  body('stock_quantity').isInt({ min: 1 }).withMessage('Stock quantity must be at least 1')
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

    if (req.user.userType !== 'seller') {
      return res.status(403).json({
        success: false,
        message: 'Only sellers can create products'
      });
    }

    const { title, description, price, category, condition, stock_quantity, images, video_url } = req.body;

    const result = await pool.query(
      `INSERT INTO products (seller_id, title, description, price, category, condition, stock_quantity, images, video_url)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [req.user.userId, title, description, price, category, condition, stock_quantity, images || [], video_url]
    );

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: {
        product: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error creating product'
    });
  }
});

// Update product (seller only)
router.put('/:id', auth, [
  body('title').optional().notEmpty().withMessage('Title cannot be empty'),
  body('description').optional().notEmpty().withMessage('Description cannot be empty'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('category').optional().notEmpty().withMessage('Category cannot be empty'),
  body('condition').optional().isIn(['new', 'used', 'refurbished']).withMessage('Invalid condition'),
  body('stock_quantity').optional().isInt({ min: 0 }).withMessage('Stock quantity must be at least 0')
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

    const { id } = req.params;

    // Check if product belongs to seller
    const productCheck = await pool.query(
      'SELECT seller_id FROM products WHERE id = $1',
      [id]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    if (productCheck.rows[0].seller_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own products'
      });
    }

    const updates = [];
    const values = [];
    let paramIndex = 1;

    const allowedFields = ['title', 'description', 'price', 'category', 'condition', 'stock_quantity', 'images', 'video_url', 'is_active'];
    
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates.push(`${field} = $${paramIndex}`);
        values.push(req.body[field]);
        paramIndex++;
      }
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid fields to update'
      });
    }

    updates.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const result = await pool.query(
      `UPDATE products SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );

    res.json({
      success: true,
      message: 'Product updated successfully',
      data: {
        product: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating product'
    });
  }
});

// Delete product (seller only)
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if product belongs to seller
    const productCheck = await pool.query(
      'SELECT seller_id FROM products WHERE id = $1',
      [id]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    if (productCheck.rows[0].seller_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own products'
      });
    }

    await pool.query('UPDATE products SET is_active = false WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Product deleted successfully'
    });
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deleting product'
    });
  }
});

// Get seller's products
router.get('/seller/me', auth, async (req, res) => {
  try {
    if (req.user.userType !== 'seller') {
      return res.status(403).json({
        success: false,
        message: 'Only sellers can view their products'
      });
    }

    const { page = 1, limit = 20, status = 'all' } = req.query;

    let query = `
      SELECT p.*, COALESCE(AVG(r.rating), 0) as average_rating,
             COUNT(r.id) as review_count
      FROM products p
      LEFT JOIN reviews r ON p.id = r.product_id
      WHERE p.seller_id = $1
    `;

    const params = [req.user.userId];
    let paramIndex = 2;

    if (status !== 'all') {
      if (status === 'active') {
        query += ` AND p.is_active = true`;
      } else if (status === 'inactive') {
        query += ` AND p.is_active = false`;
      }
    }

    query += ` GROUP BY p.id ORDER BY p.created_at DESC`;

    // Pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: {
        products: result.rows
      }
    });
  } catch (error) {
    console.error('Get seller products error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching seller products'
    });
  }
});

module.exports = router;
