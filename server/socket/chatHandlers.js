const jwt = require('jsonwebtoken');
const pool = require('../database/connection');

const chatHandlers = (io) => {
  // Authentication middleware for socket connections
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Verify user exists
      const user = await pool.query(
        'SELECT id, username, user_type FROM users WHERE id = $1',
        [decoded.userId]
      );

      if (user.rows.length === 0) {
        return next(new Error('User not found'));
      }

      socket.userId = decoded.userId;
      socket.userType = decoded.userType;
      socket.username = user.rows[0].username;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User ${socket.username} connected`);

    // Join user to their personal room for notifications
    socket.join(`user_${socket.userId}`);

    // Handle joining a specific chat room
    socket.on('join_chat', async (chatId) => {
      try {
        // Verify user is part of this chat
        const chatCheck = await pool.query(
          'SELECT id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
          [chatId, socket.userId]
        );

        if (chatCheck.rows.length > 0) {
          socket.join(`chat_${chatId}`);
          socket.emit('joined_chat', { chatId });
        } else {
          socket.emit('error', { message: 'Chat not found or access denied' });
        }
      } catch (error) {
        console.error('Join chat error:', error);
        socket.emit('error', { message: 'Server error joining chat' });
      }
    });

    // Handle sending messages
    socket.on('send_message', async (data) => {
      try {
        const { chatId, message, messageType = 'text', fileUrl } = data;

        // Verify user is part of this chat
        const chatCheck = await pool.query(
          'SELECT id, buyer_id, seller_id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
          [chatId, socket.userId]
        );

        if (chatCheck.rows.length === 0) {
          socket.emit('error', { message: 'Chat not found or access denied' });
          return;
        }

        // Create message
        const newMessage = await pool.query(
          `INSERT INTO chat_messages (chat_id, sender_id, message, message_type, file_url)
           VALUES ($1, $2, $3, $4, $5) RETURNING *`,
          [chatId, socket.userId, message, messageType, fileUrl]
        );

        // Update chat's last message
        await pool.query(
          'UPDATE chats SET last_message = $1, last_message_time = CURRENT_TIMESTAMP WHERE id = $2',
          [message, chatId]
        );

        // Get sender info
        const senderInfo = await pool.query(
          'SELECT username, full_name FROM users WHERE id = $1',
          [socket.userId]
        );

        const messageData = {
          ...newMessage.rows[0],
          sender_name: senderInfo.rows[0].username,
          sender_full_name: senderInfo.rows[0].full_name
        };

        // Send message to all users in the chat room
        io.to(`chat_${chatId}`).emit('new_message', messageData);

        // Send notification to the other user if they're not in the chat
        const otherUserId = chatCheck.rows[0].buyer_id === socket.userId 
          ? chatCheck.rows[0].seller_id 
          : chatCheck.rows[0].buyer_id;

        const socketsInChat = io.sockets.adapter.rooms.get(`chat_${chatId}`);
        if (!socketsInChat || socketsInChat.size <= 1) {
          io.to(`user_${otherUserId}`).emit('new_message_notification', {
            chatId,
            message: messageData,
            sender_name: senderInfo.rows[0].username
          });
        }

      } catch (error) {
        console.error('Send message error:', error);
        socket.emit('error', { message: 'Server error sending message' });
      }
    });

    // Handle marking messages as read
    socket.on('mark_messages_read', async (chatId) => {
      try {
        // Verify user is part of this chat
        const chatCheck = await pool.query(
          'SELECT id FROM chats WHERE id = $1 AND (buyer_id = $2 OR seller_id = $2) AND is_active = true',
          [chatId, socket.userId]
        );

        if (chatCheck.rows.length === 0) {
          socket.emit('error', { message: 'Chat not found or access denied' });
          return;
        }

        // Mark messages as read
        await pool.query(
          'UPDATE chat_messages SET is_read = true WHERE chat_id = $1 AND sender_id != $2',
          [chatId, socket.userId]
        );

        // Notify other user that messages were read
        io.to(`chat_${chatId}`).emit('messages_read', {
          chatId,
          read_by: socket.userId
        });

      } catch (error) {
        console.error('Mark messages read error:', error);
        socket.emit('error', { message: 'Server error marking messages as read' });
      }
    });

    // Handle typing indicators
    socket.on('typing_start', (chatId) => {
      socket.to(`chat_${chatId}`).emit('user_typing', {
        chatId,
        user_id: socket.userId,
        username: socket.username
      });
    });

    socket.on('typing_stop', (chatId) => {
      socket.to(`chat_${chatId}`).emit('user_stop_typing', {
        chatId,
        user_id: socket.userId
      });
    });

    // Handle user online status
    socket.on('user_online', () => {
      // Notify friends that user is online
      socket.broadcast.emit('user_status_change', {
        user_id: socket.userId,
        username: socket.username,
        status: 'online'
      });
    });

    // Handle disconnect
    socket.on('disconnect', () => {
      console.log(`User ${socket.username} disconnected`);
      
      // Notify friends that user is offline
      socket.broadcast.emit('user_status_change', {
        user_id: socket.userId,
        username: socket.username,
        status: 'offline'
      });
    });

    // Handle errors
    socket.on('error', (error) => {
      console.error('Socket error:', error);
    });
  });
};

module.exports = chatHandlers;
