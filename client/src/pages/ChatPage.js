import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { FiSend, FiPaperclip, FiArrowLeft, FiPhone, FiVideo } from 'react-icons/fi';
import { useChat } from '../contexts/ChatContext';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import toast from 'react-toastify';

const ChatPage = () => {
  const { id: chatId } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { socket, joinChat, sendMessage, markMessagesRead, isUserTyping, getTypingUser } = useChat();
  const [message, setMessage] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);
  const queryClient = useQueryClient();

  // Fetch chat list
  const { data: chatsData } = useQuery(
    'chats',
    async () => {
      const response = await axios.get('/api/chat');
      return response.data.data;
    }
  );

  // Fetch current chat
  const { data: chatData, isLoading } = useQuery(
    ['chat', chatId],
    async () => {
      if (!chatId) return null;
      const response = await axios.get(`/api/chat/${chatId}`);
      return response.data.data;
    },
    {
      enabled: !!chatId,
      onSuccess: (data) => {
        if (socket && data?.chat?.id) {
          joinChat(data.chat.id);
          markMessagesRead(data.chat.id);
        }
      }
    }
  );

  // Send message mutation
  const sendMessageMutation = useMutation(
    async (messageData) => {
      const response = await axios.post(`/api/chat/${chatId}/messages`, messageData);
      return response.data.data;
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['chat', chatId]);
        queryClient.invalidateQueries('chats');
      }
    }
  );

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [chatData?.messages]);

  useEffect(() => {
    if (socket && chatId) {
      joinChat(chatId);
    }
  }, [socket, chatId, joinChat]);

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!message.trim()) return;

    const messageData = {
      message: message.trim(),
      message_type: 'text'
    };

    // Send via socket for real-time
    sendMessage(chatId, message.trim(), 'text');
    
    // Also send via API for persistence
    await sendMessageMutation.mutateAsync(messageData);
    
    setMessage('');
    setIsTyping(false);
  };

  const handleTypingStart = () => {
    if (!isTyping) {
      setIsTyping(true);
      if (socket) {
        socket.emit('typing_start', chatId);
      }
    }
  };

  const handleTypingStop = () => {
    if (isTyping) {
      setIsTyping(false);
      if (socket) {
        socket.emit('typing_stop', chatId);
      }
    }
  };

  const handleChatSelect = (selectedChatId) => {
    navigate(`/chat/${selectedChatId}`);
  };

  const formatTime = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString('en-US', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: true 
    });
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    } else {
      return date.toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric' 
      });
    }
  };

  if (isLoading) {
    return (
      <div className="chat-loading">
        <div className="spinner"></div>
        <p>Loading chat...</p>
      </div>
    );
  }

  const chats = chatsData?.chats || [];
  const currentChat = chatData?.chat;
  const messages = chatData?.messages || [];

  return (
    <div className="chat-container">
      {/* Chat Sidebar */}
      <div className="chat-sidebar">
        <div className="chat-sidebar-header">
          <h3>Messages</h3>
          <button 
            className="new-chat-btn"
            onClick={() => navigate('/products')}
          >
            New Chat
          </button>
        </div>
        
        <div className="chat-list">
          {chats.map((chat) => (
            <div
              key={chat.id}
              className={`chat-list-item ${chat.id === chatId ? 'active' : ''}`}
              onClick={() => handleChatSelect(chat.id)}
            >
              <div className="chat-item-header">
                <span className="chat-item-name">
                  {user?.user_type === 'seller' ? chat.buyer_name : chat.seller_name}
                </span>
                <span className="chat-item-time">
                  {formatDate(chat.last_message_time)}
                </span>
              </div>
              <div className="chat-item-preview">
                <span>{chat.last_message || 'No messages yet'}</span>
                {chat.unread_count > 0 && (
                  <span className="chat-item-unread">{chat.unread_count}</span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Chat Main Area */}
      <div className="chat-main">
        {currentChat ? (
          <>
            {/* Chat Header */}
            <div className="chat-header">
              <button 
                className="back-btn"
                onClick={() => navigate('/chat')}
              >
                <FiArrowLeft />
              </button>
              <div className="chat-header-info">
                <h3>
                  {user?.user_type === 'seller' ? currentChat.buyer_name : currentChat.seller_name}
                </h3>
                <p>Product: {currentChat.product_title}</p>
              </div>
              <div className="chat-header-actions">
                <button className="action-btn">
                  <FiPhone />
                </button>
                <button className="action-btn">
                  <FiVideo />
                </button>
              </div>
            </div>

            {/* Messages */}
            <div className="chat-messages">
              {messages.map((msg, index) => {
                const isOwn = msg.sender_id === user?.id;
                const showDate = index === 0 || 
                  new Date(messages[index - 1].created_at).toDateString() !== 
                  new Date(msg.created_at).toDateString();

                return (
                  <div key={msg.id}>
                    {showDate && (
                      <div className="message-date-divider">
                        {formatDate(msg.created_at)}
                      </div>
                    )}
                    <div className={`message ${isOwn ? 'own' : ''}`}>
                      <div className="message-avatar">
                        {isOwn ? 'You' : msg.sender_name?.[0]?.toUpperCase()}
                      </div>
                      <div className="message-content">
                        <div className="message-bubble">
                          {msg.message}
                        </div>
                        <div className="message-time">
                          {formatTime(msg.created_at)}
                          {isOwn && (
                            <span className="message-status">
                              {msg.is_read ? 'Read' : 'Sent'}
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
              
              {isUserTyping(chatId) && (
                <div className="typing-indicator">
                  <span>{getTypingUser(chatId)?.username} is typing...</span>
                </div>
              )}
              
              <div ref={messagesEndRef} />
            </div>

            {/* Chat Input */}
            <div className="chat-input">
              <form onSubmit={handleSendMessage}>
                <div className="input-group">
                  <button type="button" className="attachment-btn">
                    <FiPaperclip />
                  </button>
                  <input
                    ref={inputRef}
                    type="text"
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    onFocus={handleTypingStart}
                    onBlur={handleTypingStop}
                    placeholder="Type a message..."
                    className="message-input"
                  />
                  <button 
                    type="submit" 
                    className="send-btn"
                    disabled={!message.trim() || sendMessageMutation.isLoading}
                  >
                    <FiSend />
                  </button>
                </div>
              </form>
            </div>
          </>
        ) : (
          <div className="chat-empty">
            <div className="empty-state">
              <h3>Select a conversation</h3>
              <p>Choose a chat from the sidebar to start messaging</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ChatPage;
