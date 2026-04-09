import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import Navbar from './components/Navbar';
import HomePage from './pages/HomePage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ProductsPage from './pages/ProductsPage';
import ProductDetailPage from './pages/ProductDetailPage';
import VideoFeedPage from './pages/VideoFeedPage';
import ChatPage from './pages/ChatPage';
import ProfilePage from './pages/ProfilePage';
import SellerDashboard from './pages/SellerDashboard';
import CartPage from './pages/CartPage';
import OrdersPage from './pages/OrdersPage';
import './App.css';

function App() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Loading IDUKA...</p>
      </div>
    );
  }

  return (
    <div className="App">
      <Navbar />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/login" element={!user ? <LoginPage /> : <Navigate to="/dashboard" />} />
          <Route path="/register" element={!user ? <RegisterPage /> : <Navigate to="/dashboard" />} />
          <Route path="/products" element={<ProductsPage />} />
          <Route path="/products/:id" element={<ProductDetailPage />} />
          <Route path="/videos" element={<VideoFeedPage />} />
          <Route path="/chat" element={user ? <ChatPage /> : <Navigate to="/login" />} />
          <Route path="/chat/:id" element={user ? <ChatPage /> : <Navigate to="/login" />} />
          <Route path="/profile" element={user ? <ProfilePage /> : <Navigate to="/login" />} />
          <Route path="/dashboard" element={user ? <SellerDashboard /> : <Navigate to="/login" />} />
          <Route path="/cart" element={user ? <CartPage /> : <Navigate to="/login" />} />
          <Route path="/orders" element={user ? <OrdersPage /> : <Navigate to="/login" />} />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </main>
    </div>
  );
}

export default App;
