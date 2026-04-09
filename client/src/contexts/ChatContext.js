import React, { createContext, useContext, useState, useEffect } from 'react';
import io from 'socket.io-client';
import { useAuth } from './AuthContext';
import { toast } from 'react-toastify';

const ChatContext = createContext();

export const useChat = () => {
  const context = useContext(ChatContext);
  if (!context) {
    throw new Error('useChat must be used within a ChatProvider');
  }
  return context;
};

export const ChatProvider = ({ children }) => {
  const [socket, setSocket] = useState(null);
  const [onlineUsers, setOnlineUsers] = useState(new Set());
  const [typingUsers, setTypingUsers] = useState(new Map());
  const { user, isAuthenticated } = useAuth();

  useEffect(() => {
    if (isAuthenticated && user) {
      const token = localStorage.getItem('token');
      const newSocket = io(process.env.REACT_APP_SERVER_URL || 'http://localhost:5000', {
        auth: {
          token: token
        }
      });

      newSocket.on('connect', () => {
        console.log('Connected to chat server');
        newSocket.emit('user_online');
      });

      newSocket.on('disconnect', () => {
        console.log('Disconnected from chat server');
      });

      newSocket.on('new_message', (message) => {
        // This will be handled by individual chat components
        console.log('New message received:', message);
      });

      newSocket.on('new_message_notification', (notification) => {
        toast.info(`New message from ${notification.sender_name}: ${notification.message.message.substring(0, 50)}...`);
      });

      newSocket.on('user_status_change', (statusChange) => {
        if (statusChange.status === 'online') {
          setOnlineUsers(prev => new Set(prev).add(statusChange.user_id));
        } else {
          setOnlineUsers(prev => {
            const newSet = new Set(prev);
            newSet.delete(statusChange.user_id);
            return newSet;
          });
        }
      });

      newSocket.on('user_typing', (typingData) => {
        setTypingUsers(prev => new Map(prev).set(typingData.chatId, {
          user_id: typingData.user_id,
          username: typingData.username
        }));
      });

      newSocket.on('user_stop_typing', (typingData) => {
        setTypingUsers(prev => {
          const newMap = new Map(prev);
          newMap.delete(typingData.chatId);
          return newMap;
        });
      });

      newSocket.on('messages_read', (readData) => {
        // Handle messages being read
        console.log('Messages read:', readData);
      });

      newSocket.on('error', (error) => {
        console.error('Socket error:', error);
        toast.error(error.message || 'Connection error');
      });

      setSocket(newSocket);

      return () => {
        newSocket.close();
      };
    }
  }, [isAuthenticated, user]);

  const joinChat = (chatId) => {
    if (socket) {
      socket.emit('join_chat', chatId);
    }
  };

  const sendMessage = (chatId, message, messageType = 'text', fileUrl = null) => {
    if (socket) {
      socket.emit('send_message', {
        chatId,
        message,
        messageType,
        fileUrl
      });
    }
  };

  const markMessagesRead = (chatId) => {
    if (socket) {
      socket.emit('mark_messages_read', chatId);
    }
  };

  const startTyping = (chatId) => {
    if (socket) {
      socket.emit('typing_start', chatId);
    }
  };

  const stopTyping = (chatId) => {
    if (socket) {
      socket.emit('typing_stop', chatId);
    }
  };

  const isUserOnline = (userId) => {
    return onlineUsers.has(userId);
  };

  const isUserTyping = (chatId) => {
    return typingUsers.has(chatId);
  };

  const getTypingUser = (chatId) => {
    return typingUsers.get(chatId);
  };

  const value = {
    socket,
    joinChat,
    sendMessage,
    markMessagesRead,
    startTyping,
    stopTyping,
    isUserOnline,
    isUserTyping,
    getTypingUser,
    onlineUsers
  };

  return (
    <ChatContext.Provider value={value}>
      {children}
    </ChatContext.Provider>
  );
};
