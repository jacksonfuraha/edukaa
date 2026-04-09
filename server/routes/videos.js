const express = require('express');
const multer = require('multer');
const path = require('path');
const { body, validationResult } = require('express-validator');
const pool = require('../database/connection');
const auth = require('../middleware/auth');
const router = express.Router();

// Configure multer for video uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/videos/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  // Accept video files only
  if (file.mimetype.startsWith('video/')) {
    cb(null, true);
  } else {
    cb(new Error('Only video files are allowed'), false);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit
  },
  fileFilter: fileFilter
});

// Get TikTok-style video feed
router.get('/feed', async (req, res) => {
  try {
    const { page = 1, limit = 10, category } = req.query;

    let query = `
      SELECT pv.*, p.title, p.price, p.category, p.images,
             u.username as seller_name, u.full_name as seller_full_name,
             u.profile_image as seller_avatar,
             COALESCE(AVG(r.rating), 0) as average_rating,
             COUNT(DISTINCT r.id) as review_count,
             COUNT(DISTINCT pv.id) OVER() as total_videos
      FROM product_videos pv
      JOIN products p ON pv.product_id = p.id
      JOIN users u ON p.seller_id = u.id
      LEFT JOIN reviews r ON p.id = r.product_id
      WHERE pv.is_active = true AND p.is_active = true
    `;

    const params = [];
    let paramIndex = 1;

    if (category) {
      query += ` AND p.category = $${paramIndex}`;
      params.push(category);
      paramIndex++;
    }

    query += ` GROUP BY pv.id, p.title, p.price, p.category, p.images, u.username, u.full_name, u.profile_image`;
    query += ` ORDER BY pv.created_at DESC`;

    // Pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: {
        videos: result.rows,
        pagination: {
          current_page: parseInt(page),
          has_more: result.rows.length === parseInt(limit)
        }
      }
    });
  } catch (error) {
    console.error('Get video feed error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching video feed'
    });
  }
});

// Get videos for a specific product
router.get('/product/:productId', async (req, res) => {
  try {
    const { productId } = req.params;

    const query = `
      SELECT pv.*, p.title, p.price, p.category,
             u.username as seller_name, u.full_name as seller_full_name
      FROM product_videos pv
      JOIN products p ON pv.product_id = p.id
      JOIN users u ON p.seller_id = u.id
      WHERE pv.product_id = $1 AND pv.is_active = true AND p.is_active = true
      ORDER BY pv.created_at DESC
    `;

    const result = await pool.query(query, [productId]);

    res.json({
      success: true,
      data: {
        videos: result.rows
      }
    });
  } catch (error) {
    console.error('Get product videos error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching product videos'
    });
  }
});

// Upload video for product (seller only)
router.post('/upload', auth, upload.single('video'), [
  body('product_id').notEmpty().withMessage('Product ID is required'),
  body('caption').optional().isLength({ max: 500 }).withMessage('Caption too long')
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
        message: 'Only sellers can upload videos'
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No video file provided'
      });
    }

    const { product_id, caption } = req.body;

    // Check if product belongs to seller
    const productCheck = await pool.query(
      'SELECT seller_id FROM products WHERE id = $1 AND is_active = true',
      [product_id]
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
        message: 'You can only upload videos for your own products'
      });
    }

    // Create video record
    const videoUrl = `/uploads/videos/${req.file.filename}`;
    
    const result = await pool.query(
      `INSERT INTO product_videos (product_id, video_url, caption)
       VALUES ($1, $2, $3) RETURNING *`,
      [product_id, videoUrl, caption]
    );

    res.status(201).json({
      success: true,
      message: 'Video uploaded successfully',
      data: {
        video: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Upload video error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error uploading video'
    });
  }
});

// Update video (seller only)
router.put('/:id', auth, [
  body('caption').optional().isLength({ max: 500 }).withMessage('Caption too long'),
  body('is_active').optional().isBoolean().withMessage('is_active must be boolean')
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

    // Check if video belongs to seller's product
    const videoCheck = await pool.query(
      `SELECT pv.product_id, p.seller_id 
       FROM product_videos pv
       JOIN products p ON pv.product_id = p.id
       WHERE pv.id = $1`,
      [id]
    );

    if (videoCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    if (videoCheck.rows[0].seller_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own videos'
      });
    }

    const updates = [];
    const values = [];
    let paramIndex = 1;

    if (req.body.caption !== undefined) {
      updates.push(`caption = $${paramIndex}`);
      values.push(req.body.caption);
      paramIndex++;
    }

    if (req.body.is_active !== undefined) {
      updates.push(`is_active = $${paramIndex}`);
      values.push(req.body.is_active);
      paramIndex++;
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid fields to update'
      });
    }

    values.push(id);

    const result = await pool.query(
      `UPDATE product_videos SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );

    res.json({
      success: true,
      message: 'Video updated successfully',
      data: {
        video: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Update video error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating video'
    });
  }
});

// Delete video (seller only)
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if video belongs to seller's product
    const videoCheck = await pool.query(
      `SELECT pv.product_id, p.seller_id 
       FROM product_videos pv
       JOIN products p ON pv.product_id = p.id
       WHERE pv.id = $1`,
      [id]
    );

    if (videoCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    if (videoCheck.rows[0].seller_id !== req.user.userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own videos'
      });
    }

    // Soft delete video
    await pool.query('UPDATE product_videos SET is_active = false WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Video deleted successfully'
    });
  } catch (error) {
    console.error('Delete video error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deleting video'
    });
  }
});

// Get seller's videos
router.get('/seller/me', auth, async (req, res) => {
  try {
    if (req.user.userType !== 'seller') {
      return res.status(403).json({
        success: false,
        message: 'Only sellers can view their videos'
      });
    }

    const { page = 1, limit = 20 } = req.query;

    const query = `
      SELECT pv.*, p.title, p.price, p.category, p.is_active as product_active
      FROM product_videos pv
      JOIN products p ON pv.product_id = p.id
      WHERE p.seller_id = $1
      ORDER BY pv.created_at DESC
    `;

    // Pagination
    const offset = (page - 1) * limit;
    const paginatedQuery = query + ` LIMIT $2 OFFSET $3`;

    const result = await pool.query(paginatedQuery, [req.user.userId, limit, offset]);

    res.json({
      success: true,
      data: {
        videos: result.rows
      }
    });
  } catch (error) {
    console.error('Get seller videos error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching seller videos'
    });
  }
});

// Like video (for engagement metrics)
router.post('/:id/like', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if video exists
    const videoCheck = await pool.query(
      'SELECT id FROM product_videos WHERE id = $1 AND is_active = true',
      [id]
    );

    if (videoCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    // This is a simplified like system - in production you'd have a separate likes table
    // For now, we'll just return success
    res.json({
      success: true,
      message: 'Video liked successfully'
    });
  } catch (error) {
    console.error('Like video error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error liking video'
    });
  }
});

module.exports = router;
