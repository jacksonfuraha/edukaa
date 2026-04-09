const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../database/connection');
const auth = require('../middleware/auth');
const router = express.Router();

// Get user profile
router.get('/profile', auth, async (req, res) => {
  try {
    const query = `
      SELECT u.id, u.username, u.email, u.full_name, u.phone, u.user_type, 
             u.profile_image, u.is_verified, u.created_at,
             a.country, a.province, a.district, a.sector, a.cell, a.village, a.street_address
      FROM users u
      LEFT JOIN addresses a ON u.id = a.user_id AND a.is_default = true
      WHERE u.id = $1
    `;

    const result = await pool.query(query, [req.user.userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: {
        user: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching profile'
    });
  }
});

// Update user profile
router.put('/profile', auth, [
  body('full_name').optional().isLength({ min: 2 }).withMessage('Full name must be at least 2 characters'),
  body('phone').optional().isLength({ min: 10 }).withMessage('Phone number must be at least 10 characters'),
  body('username').optional().isLength({ min: 3 }).withMessage('Username must be at least 3 characters')
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

    const updates = [];
    const values = [];
    let paramIndex = 1;

    const allowedFields = ['full_name', 'phone', 'username'];
    
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        // Check if username is already taken
        if (field === 'username') {
          const existingUser = await pool.query(
            'SELECT id FROM users WHERE username = $1 AND id != $2',
            [req.body[field], req.user.userId]
          );
          
          if (existingUser.rows.length > 0) {
            return res.status(400).json({
              success: false,
              message: 'Username is already taken'
            });
          }
        }
        
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

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(req.user.userId);

    const result = await pool.query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING id, username, email, full_name, phone, user_type, profile_image, is_verified, created_at, updated_at`,
      values
    );

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating profile'
    });
  }
});

// Get user addresses
router.get('/addresses', auth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM addresses WHERE user_id = $1 ORDER BY is_default DESC, created_at DESC',
      [req.user.userId]
    );

    res.json({
      success: true,
      data: {
        addresses: result.rows
      }
    });
  } catch (error) {
    console.error('Get addresses error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching addresses'
    });
  }
});

// Add new address
router.post('/addresses', auth, [
  body('country').notEmpty().withMessage('Country is required'),
  body('province').notEmpty().withMessage('Province is required'),
  body('district').notEmpty().withMessage('District is required'),
  body('sector').notEmpty().withMessage('Sector is required'),
  body('cell').notEmpty().withMessage('Cell is required'),
  body('village').notEmpty().withMessage('Village is required')
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

    const { country, province, district, sector, cell, village, street_address, is_default } = req.body;

    // If this is set as default, unset other default addresses
    if (is_default) {
      await pool.query('UPDATE addresses SET is_default = false WHERE user_id = $1', [req.user.userId]);
    }

    const result = await pool.query(
      `INSERT INTO addresses (user_id, country, province, district, sector, cell, village, street_address, is_default)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [req.user.userId, country, province, district, sector, cell, village, street_address, is_default || false]
    );

    res.status(201).json({
      success: true,
      message: 'Address added successfully',
      data: {
        address: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Add address error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error adding address'
    });
  }
});

// Update address
router.put('/addresses/:id', auth, [
  body('country').optional().notEmpty().withMessage('Country cannot be empty'),
  body('province').optional().notEmpty().withMessage('Province cannot be empty'),
  body('district').optional().notEmpty().withMessage('District cannot be empty'),
  body('sector').optional().notEmpty().withMessage('Sector cannot be empty'),
  body('cell').optional().notEmpty().withMessage('Cell cannot be empty'),
  body('village').optional().notEmpty().withMessage('Village cannot be empty')
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

    // Check if address belongs to user
    const addressCheck = await pool.query(
      'SELECT id FROM addresses WHERE id = $1 AND user_id = $2',
      [id, req.user.userId]
    );

    if (addressCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }

    const updates = [];
    const values = [];
    let paramIndex = 1;

    const allowedFields = ['country', 'province', 'district', 'sector', 'cell', 'village', 'street_address', 'is_default'];
    
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

    // If setting as default, unset other default addresses
    if (req.body.is_default) {
      await pool.query('UPDATE addresses SET is_default = false WHERE user_id = $1 AND id != $2', [req.user.userId, id]);
    }

    values.push(id);

    const result = await pool.query(
      `UPDATE addresses SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      values
    );

    res.json({
      success: true,
      message: 'Address updated successfully',
      data: {
        address: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Update address error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating address'
    });
  }
});

// Delete address
router.delete('/addresses/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if address belongs to user
    const addressCheck = await pool.query(
      'SELECT id, is_default FROM addresses WHERE id = $1 AND user_id = $2',
      [id, req.user.userId]
    );

    if (addressCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Address not found'
      });
    }

    // Don't allow deletion of default address if user has other addresses
    if (addressCheck.rows[0].is_default) {
      const otherAddresses = await pool.query(
        'SELECT COUNT(*) as count FROM addresses WHERE user_id = $1 AND id != $2',
        [req.user.userId, id]
      );

      if (parseInt(otherAddresses.rows[0].count) > 0) {
        return res.status(400).json({
          success: false,
          message: 'Cannot delete default address. Set another address as default first.'
        });
      }
    }

    await pool.query('DELETE FROM addresses WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Address deleted successfully'
    });
  } catch (error) {
    console.error('Delete address error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deleting address'
    });
  }
});

// Get seller's public profile
router.get('/seller/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      SELECT u.id, u.username, u.full_name, u.profile_image, u.is_verified, u.created_at,
             COUNT(DISTINCT p.id) as total_products,
             COUNT(DISTINCT o.id) as total_orders,
             COALESCE(AVG(r.rating), 0) as average_rating,
             COUNT(DISTINCT r.id) as total_reviews
      FROM users u
      LEFT JOIN products p ON u.id = p.seller_id AND p.is_active = true
      LEFT JOIN orders o ON u.id = o.seller_id AND o.status = 'delivered'
      LEFT JOIN reviews r ON u.id = r.seller_id
      WHERE u.id = $1 AND u.user_type = 'seller'
      GROUP BY u.id
    `;

    const result = await pool.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Seller not found'
      });
    }

    res.json({
      success: true,
      data: {
        seller: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Get seller profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching seller profile'
    });
  }
});

// Get user's favorites
router.get('/favorites', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    const query = `
      SELECT f.*, p.title, p.price, p.category, p.condition, p.images, p.views,
             u.username as seller_name, u.full_name as seller_full_name,
             COALESCE(AVG(r.rating), 0) as average_rating,
             COUNT(r.id) as review_count
      FROM favorites f
      JOIN products p ON f.product_id = p.id
      JOIN users u ON p.seller_id = u.id
      LEFT JOIN reviews r ON p.id = r.product_id
      WHERE f.user_id = $1 AND p.is_active = true
      GROUP BY f.id, p.id, u.username, u.full_name
      ORDER BY f.created_at DESC
    `;

    // Pagination
    const offset = (page - 1) * limit;
    const paginatedQuery = query + ` LIMIT $2 OFFSET $3`;

    const result = await pool.query(paginatedQuery, [req.user.userId, limit, offset]);

    res.json({
      success: true,
      data: {
        favorites: result.rows
      }
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching favorites'
    });
  }
});

// Add to favorites
router.post('/favorites', auth, [
  body('product_id').notEmpty().withMessage('Product ID is required')
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

    const { product_id } = req.body;

    // Check if product exists
    const productCheck = await pool.query(
      'SELECT id FROM products WHERE id = $1 AND is_active = true',
      [product_id]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Check if already in favorites
    const existingFavorite = await pool.query(
      'SELECT id FROM favorites WHERE user_id = $1 AND product_id = $2',
      [req.user.userId, product_id]
    );

    if (existingFavorite.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Product already in favorites'
      });
    }

    const result = await pool.query(
      'INSERT INTO favorites (user_id, product_id) VALUES ($1, $2) RETURNING *',
      [req.user.userId, product_id]
    );

    res.status(201).json({
      success: true,
      message: 'Added to favorites',
      data: {
        favorite: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error adding to favorites'
    });
  }
});

// Remove from favorites
router.delete('/favorites/:productId', auth, async (req, res) => {
  try {
    const { productId } = req.params;

    const result = await pool.query(
      'DELETE FROM favorites WHERE user_id = $1 AND product_id = $2 RETURNING *',
      [req.user.userId, productId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Favorite not found'
      });
    }

    res.json({
      success: true,
      message: 'Removed from favorites'
    });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error removing from favorites'
    });
  }
});

module.exports = router;
