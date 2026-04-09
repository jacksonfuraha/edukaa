const express = require('express');
const { body, validationResult } = require('express-validator');
const pool = require('../database/connection');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all chats for a user
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    let query = `
      SELECT c.*, 
             p.title as product_title, p.images as product_images,
             buyer.username as buyer_name, buyer.full_name as buyer_full_name,
             seller.username as seller_name, seller.full_name as seller_full_name,
             CASE 
               WHEN c.buyer_id = $1 THEN seller.username
               ELSE buyer.username
             END as other_user_name,
             CASE 
               WHEN c.buyer_id = $1 THEN seller.full_name
               ELSE buyer.full_name
             END as other_user_full_name,
             CASE 
               WHEN c.buyer_id = $1 THEN seller.id
               ELSE buyer.id
             END as other_user_id
      FROM chats c
      JOIN products p ON c.product_id = p.id
      JOIN users buyer ON c.buyer_id = buyer.id
      JOIN users seller ON c.seller_id = seller.id
      WHERE (c.buyer_id = $1 OR c.seller_id = $1) AND c.is_active = true
      ORDER BY c.last_message_time DESC
    `;

    // Pagination
    const offset = (page - 1) * limit;
    query += ` LIMIT $2 OFFSET $3`;

    const result = await pool.query(query, [req.user.userId, limit, offset]);

    // Get unread message count for each chat
    const chatsWithUnread = await Promise.all(
      result.rows.map(async (chat) => {
        const unreadCount = await pool.query(
          `SELECT COUNT(*) as count FROM chat_messages 
           WHERE chat_id = $1 AND sender_id != $2 AND is_read = false`,
          [chat.id, req.user.userId]
        );

        return {
          ...chat,
          unread_count: parseInt(unreadCount.rows[0].count)
        };
      })
    );

    res.json({
      success: true,
      data: {
        chats: chatsWithUnread
      }
    });
  } catch (error) {
    console.error('Get chats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching chats'
    });
  }
});

// Get single chat with messages
router.get('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is part of this chat
    const chatCheck = await pool.query(
      'SELECT id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
      [id, req.user.userId]
    );

    if (chatCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    // Get chat details
    const chatQuery = `
      SELECT c.*, 
             p.title as product_title, p.images as product_images, p.price as product_price,
             buyer.username as buyer_name, buyer.full_name as buyer_full_name,
             seller.username as seller_name, seller.full_name as seller_full_name,
             CASE 
               WHEN c.buyer_id = $1 THEN seller.username
               ELSE buyer.username
             END as other_user_name,
             CASE 
               WHEN c.buyer_id = $1 THEN seller.full_name
               ELSE buyer.full_name
             END as other_user_full_name,
             CASE 
               WHEN c.buyer_id = $1 THEN seller.id
               ELSE buyer.id
             END as other_user_id
      FROM chats c
      JOIN products p ON c.product_id = p.id
      JOIN users buyer ON c.buyer_id = buyer.id
      JOIN users seller ON c.seller_id = seller.id
      WHERE c.id = $2
    `;

    const chatResult = await pool.query(chatQuery, [req.user.userId, id]);

    // Get messages
    const messagesQuery = `
      SELECT cm.*, u.username as sender_name
      FROM chat_messages cm
      JOIN users u ON cm.sender_id = u.id
      WHERE cm.chat_id = $1
      ORDER BY cm.created_at ASC
    `;

    const messagesResult = await pool.query(messagesQuery, [id]);

    // Mark messages as read
    await pool.query(
      'UPDATE chat_messages SET is_read = true WHERE chat_id = $1 AND sender_id != $2',
      [id, req.user.userId]
    );

    res.json({
      success: true,
      data: {
        chat: chatResult.rows[0],
        messages: messagesResult.rows
      }
    });
  } catch (error) {
    console.error('Get chat error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching chat'
    });
  }
});

// Create new chat
router.post('/', auth, [
  body('product_id').notEmpty().withMessage('Product ID is required'),
  body('message').notEmpty().withMessage('Message is required')
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

    const { product_id, message } = req.body;

    // Get product details
    const product = await pool.query(
      'SELECT seller_id, title FROM products WHERE id = $1 AND is_active = true',
      [product_id]
    );

    if (product.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const sellerId = product.rows[0].seller_id;

    // Check if user is trying to chat with themselves
    if (sellerId === req.user.userId) {
      return res.status(400).json({
        success: false,
        message: 'You cannot chat with yourself'
      });
    }

    // Check if chat already exists
    const existingChat = await pool.query(
      'SELECT id FROM chats WHERE buyer_id = $1 AND seller_id = $2 AND product_id = $3 AND is_active = true',
      [req.user.userId, sellerId, product_id]
    );

    let chatId;

    if (existingChat.rows.length > 0) {
      chatId = existingChat.rows[0].id;
    } else {
      // Create new chat
      const newChat = await pool.query(
        `INSERT INTO chats (buyer_id, seller_id, product_id, last_message, last_message_time)
         VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP) RETURNING id`,
        [req.user.userId, sellerId, product_id, message]
      );
      chatId = newChat.rows[0].id;
    }

    // Create first message
    await pool.query(
      `INSERT INTO chat_messages (chat_id, sender_id, message)
       VALUES ($1, $2, $3)`,
      [chatId, req.user.userId, message]
    );

    res.status(201).json({
      success: true,
      message: 'Chat created successfully',
      data: {
        chat_id: chatId
      }
    });
  } catch (error) {
    console.error('Create chat error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error creating chat'
    });
  }
});

// Send message
router.post('/:id/messages', auth, [
  body('message').notEmpty().withMessage('Message is required')
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
    const { message, message_type = 'text', file_url } = req.body;

    // Check if user is part of this chat
    const chatCheck = await pool.query(
      'SELECT id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
      [id, req.user.userId]
    );

    if (chatCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    // Create message
    const newMessage = await pool.query(
      `INSERT INTO chat_messages (chat_id, sender_id, message, message_type, file_url)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [id, req.user.userId, message, message_type, file_url]
    );

    // Update chat's last message
    await pool.query(
      'UPDATE chats SET last_message = $1, last_message_time = CURRENT_TIMESTAMP WHERE id = $2',
      [message, id]
    );

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: {
        message: newMessage.rows[0]
      }
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error sending message'
    });
  }
});

// Mark messages as read
router.put('/:id/read', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is part of this chat
    const chatCheck = await pool.query(
      'SELECT id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
      [id, req.user.userId]
    );

    if (chatCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    // Mark messages as read
    await pool.query(
      'UPDATE chat_messages SET is_read = true WHERE chat_id = $1 AND sender_id != $2',
      [id, req.user.userId]
    );

    res.json({
      success: true,
      message: 'Messages marked as read'
    });
  } catch (error) {
    console.error('Mark messages read error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error marking messages as read'
    });
  }
});

// Delete chat
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user is part of this chat
    const chatCheck = await pool.query(
      'SELECT id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
      [id, req.user.userId]
    );

    if (chatCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Chat not found'
      });
    }

    // Soft delete chat
    await pool.query('UPDATE chats SET is_active = false WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Chat deleted successfully'
    });
  } catch (error) {
    console.error('Delete chat error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deleting chat'
    });
  }
});

module.exports = router;
