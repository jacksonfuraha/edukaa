const express = require('express');
const { body, validationResult } = require('express-validator');
const axios = require('axios');
const pool = require('../database/connection');
const auth = require('../middleware/auth');
const router = express.Router();

// MTN MoMo Payment Integration
router.post('/momo/initiate', auth, [
  body('amount').isFloat({ min: 100 }).withMessage('Amount must be at least 100 RWF'),
  body('phone').isLength({ min: 10, max: 15 }).withMessage('Valid phone number required'),
  body('order_id').notEmpty().withMessage('Order ID is required')
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

    const { amount, phone, order_id } = req.body;

    // Verify order belongs to user
    const orderCheck = await pool.query(
      'SELECT id, total_price, payment_status FROM orders WHERE id = $1 AND buyer_id = $2',
      [order_id, req.user.userId]
    );

    if (orderCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (orderCheck.rows[0].payment_status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Order is already paid or processed'
      });
    }

    // In production, this would integrate with actual MTN MoMo API
    // For demo purposes, we'll simulate the payment initiation
    const paymentReference = `MOMO_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Simulate API call to MTN MoMo
    try {
      // Mock response for demo
      const mockResponse = {
        success: true,
        reference: paymentReference,
        status: 'pending'
      };

      // Store payment transaction
      await pool.query(
        `INSERT INTO payment_transactions (order_id, payment_method, amount, phone, reference, status, created_at)
         VALUES ($1, 'mtn_momo', $2, $3, $4, 'pending', CURRENT_TIMESTAMP)`,
        [order_id, amount, phone, paymentReference]
      );

      res.json({
        success: true,
        message: 'Payment initiated successfully',
        data: {
          reference: paymentReference,
          amount: amount,
          phone: phone,
          status: 'pending',
          instructions: 'Please complete the payment on your mobile device'
        }
      });
    } catch (apiError) {
      console.error('MTN MoMo API Error:', apiError);
      res.status(500).json({
        success: false,
        message: 'Payment service temporarily unavailable'
      });
    }
  } catch (error) {
    console.error('Initiate MoMo payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error initiating payment'
    });
  }
});

// Airtel Money Payment Integration
router.post('/airtel/initiate', auth, [
  body('amount').isFloat({ min: 100 }).withMessage('Amount must be at least 100 RWF'),
  body('phone').isLength({ min: 10, max: 15 }).withMessage('Valid phone number required'),
  body('order_id').notEmpty().withMessage('Order ID is required')
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

    const { amount, phone, order_id } = req.body;

    // Verify order belongs to user
    const orderCheck = await pool.query(
      'SELECT id, total_price, payment_status FROM orders WHERE id = $1 AND buyer_id = $2',
      [order_id, req.user.userId]
    );

    if (orderCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (orderCheck.rows[0].payment_status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Order is already paid or processed'
      });
    }

    // In production, this would integrate with actual Airtel Money API
    const paymentReference = `AIRTEL_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Store payment transaction
    await pool.query(
      `INSERT INTO payment_transactions (order_id, payment_method, amount, phone, reference, status, created_at)
       VALUES ($1, 'airtel_money', $2, $3, $4, 'pending', CURRENT_TIMESTAMP)`,
      [order_id, amount, phone, paymentReference]
    );

    res.json({
      success: true,
      message: 'Payment initiated successfully',
      data: {
        reference: paymentReference,
        amount: amount,
        phone: phone,
        status: 'pending',
        instructions: 'Please complete the payment on your mobile device'
      }
    });
  } catch (error) {
    console.error('Initiate Airtel payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error initiating payment'
    });
  }
});

// Check payment status
router.get('/status/:reference', auth, async (req, res) => {
  try {
    const { reference } = req.params;

    const paymentQuery = `
      SELECT pt.*, o.buyer_id, o.payment_status as order_payment_status
      FROM payment_transactions pt
      JOIN orders o ON pt.order_id = o.id
      WHERE pt.reference = $1 AND o.buyer_id = $2
    `;

    const result = await pool.query(paymentQuery, [reference, req.user.userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Payment not found'
      });
    }

    const payment = result.rows[0];

    // In production, this would check with the actual payment provider
    // For demo, we'll simulate status checking
    let status = payment.status;
    
    // Simulate payment completion after some time
    if (status === 'pending' && Date.now() - new Date(payment.created_at).getTime() > 60000) {
      status = 'completed';
      
      // Update payment and order status
      await pool.query('BEGIN');
      
      await pool.query(
        'UPDATE payment_transactions SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE reference = $2',
        [status, reference]
      );
      
      await pool.query(
        'UPDATE orders SET payment_status = $1, status = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3',
        ['paid', 'confirmed', payment.order_id]
      );
      
      await pool.query('COMMIT');
    }

    res.json({
      success: true,
      data: {
        reference: reference,
        status: status,
        amount: payment.amount,
        payment_method: payment.payment_method,
        created_at: payment.created_at
      }
    });
  } catch (error) {
    console.error('Check payment status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error checking payment status'
    });
  }
});

// Create order (before payment)
router.post('/order', auth, [
  body('product_id').notEmpty().withMessage('Product ID is required'),
  body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('shipping_address').isObject().withMessage('Shipping address is required')
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

    const { product_id, quantity, shipping_address } = req.body;

    // Get product details
    const productQuery = `
      SELECT p.*, u.username as seller_name, u.full_name as seller_full_name
      FROM products p
      JOIN users u ON p.seller_id = u.id
      WHERE p.id = $1 AND p.is_active = true
    `;

    const productResult = await pool.query(productQuery, [product_id]);

    if (productResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const product = productResult.rows[0];

    // Check if user is trying to buy their own product
    if (product.seller_id === req.user.userId) {
      return res.status(400).json({
        success: false,
        message: 'You cannot buy your own product'
      });
    }

    // Check stock
    if (product.stock_quantity < quantity) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient stock available'
      });
    }

    const total_price = product.price * quantity;

    // Create order
    const orderResult = await pool.query(
      `INSERT INTO orders (buyer_id, seller_id, product_id, quantity, total_price, shipping_address, status, payment_status)
       VALUES ($1, $2, $3, $4, $5, $6, 'pending', 'pending') RETURNING *`,
      [req.user.userId, product.seller_id, product_id, quantity, total_price, JSON.stringify(shipping_address)]
    );

    // Update product stock
    await pool.query(
      'UPDATE products SET stock_quantity = stock_quantity - $1 WHERE id = $2',
      [quantity, product_id]
    );

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: {
        order: orderResult.rows[0],
        product: {
          id: product.id,
          title: product.title,
          price: product.price,
          images: product.images
        }
      }
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error creating order'
    });
  }
});

// Get user's orders
router.get('/orders', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;

    let query = `
      SELECT o.*, p.title as product_title, p.images as product_images,
             u.username as seller_name, u.full_name as seller_full_name
      FROM orders o
      JOIN products p ON o.product_id = p.id
      JOIN users u ON o.seller_id = u.id
      WHERE o.buyer_id = $1
    `;

    const params = [req.user.userId];
    let paramIndex = 2;

    if (status) {
      query += ` AND o.status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    query += ` ORDER BY o.created_at DESC`;

    // Pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: {
        orders: result.rows
      }
    });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching orders'
    });
  }
});

// Get single order details
router.get('/orders/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    const query = `
      SELECT o.*, p.title as product_title, p.description as product_description, 
             p.images as product_images, p.category, p.condition,
             u.username as seller_name, u.full_name as seller_full_name, u.phone as seller_phone,
             a.country, a.province, a.district, a.sector, a.cell, a.village, a.street_address
      FROM orders o
      JOIN products p ON o.product_id = p.id
      JOIN users u ON o.seller_id = u.id
      LEFT JOIN addresses a ON a.user_id = u.id AND a.is_default = true
      WHERE o.id = $1 AND o.buyer_id = $2
    `;

    const result = await pool.query(query, [id, req.user.userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    res.json({
      success: true,
      data: {
        order: result.rows[0]
      }
    });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching order'
    });
  }
});

// Cancel order
router.put('/orders/:id/cancel', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if order belongs to user and can be cancelled
    const orderCheck = await pool.query(
      'SELECT id, product_id, quantity, status FROM orders WHERE id = $1 AND buyer_id = $2',
      [id, req.user.userId]
    );

    if (orderCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const order = orderCheck.rows[0];

    if (order.status !== 'pending' && order.status !== 'confirmed') {
      return res.status(400).json({
        success: false,
        message: 'Order cannot be cancelled at this stage'
      });
    }

    await pool.query('BEGIN');

    // Update order status
    await pool.query(
      'UPDATE orders SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
      ['cancelled', id]
    );

    // Restore product stock
    await pool.query(
      'UPDATE products SET stock_quantity = stock_quantity + $1 WHERE id = $2',
      [order.quantity, order.product_id]
    );

    await pool.query('COMMIT');

    res.json({
      success: true,
      message: 'Order cancelled successfully'
    });
  } catch (error) {
    await pool.query('ROLLBACK');
    console.error('Cancel order error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error cancelling order'
    });
  }
});

module.exports = router;
