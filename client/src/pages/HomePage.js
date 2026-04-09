import React from 'react';
import { Link } from 'react-router-dom';
import { FiShoppingBag, FiUsers, FiVideo, FiMessageCircle, FiMapPin, FiTrendingUp, FiShield, FiSmartphone } from 'react-icons/fi';

const HomePage = () => {
  const features = [
    {
      icon: FiVideo,
      title: 'TikTok-Style Video Feed',
      description: 'Showcase your products with engaging video advertisements that customers can scroll through just like social media.'
    },
    {
      icon: FiMessageCircle,
      title: 'Real-Time Chat & Negotiation',
      description: 'Connect directly with buyers and sellers through our integrated chat system to negotiate prices and discuss products.'
    },
    {
      icon: FiMapPin,
      title: 'Comprehensive Address System',
      description: 'Detailed location tracking from country down to village level for accurate delivery across Rwanda.'
    },
    {
      icon: FiShoppingBag,
      title: 'Easy Product Management',
      description: 'Sellers can easily list products, manage inventory, and track sales through an intuitive dashboard.'
    },
    {
      icon: FiSmartphone,
      title: 'Mobile Money Integration',
      description: 'Seamless payments with MTN MoMo and Airtel Money for secure and convenient transactions.'
    },
    {
      icon: FiShield,
      title: 'Secure Platform',
      description: 'Advanced security features to protect your data and ensure safe transactions for all users.'
    }
  ];

  const stats = [
    { number: '10,000+', label: 'Active Users' },
    { number: '50,000+', label: 'Products Listed' },
    { number: '1M+', label: 'Video Views' },
    { number: '95%', label: 'Customer Satisfaction' }
  ];

  return (
    <div className="homepage">
      <div className="container">
        <div className="hero-section">
          <h1>Welcome to IDUKA</h1>
          <p>Rwanda's Premier Online Marketplace - Connecting Local Merchants with Customers Nationwide</p>
          
          <div className="auth-cards">
            <div className="auth-card">
              <div className="auth-icon">
                <FiShoppingBag />
              </div>
              <h3>Start Selling</h3>
              <p>Open your virtual shop today and reach customers across Rwanda without the high costs of physical rental spaces.</p>
              <Link to="/register" className="btn btn-primary">
                Register as Seller
              </Link>
            </div>
            
            <div className="auth-card">
              <div className="auth-icon">
                <FiUsers />
              </div>
              <h3>Start Shopping</h3>
              <p>Discover amazing products from local sellers, negotiate prices, and enjoy convenient delivery to your doorstep.</p>
              <Link to="/register" className="btn btn-secondary">
                Register as Buyer
              </Link>
            </div>
          </div>
        </div>

        <div className="stats-section">
          <div className="stats-grid">
            {stats.map((stat, index) => (
              <div key={index} className="stat-card">
                <div className="stat-number">{stat.number}</div>
                <div className="stat-label">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="features-section">
          <h2>Why Choose IDUKA?</h2>
          <div className="features-grid">
            {features.map((feature, index) => (
              <div key={index} className="feature-card">
                <div className="feature-icon">
                  <feature.icon />
                </div>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
              </div>
            ))}
          </div>
        </div>

        <div className="how-it-works">
          <h2>How IDUKA Works</h2>
          <div className="steps-grid">
            <div className="step-card">
              <div className="step-number">1</div>
              <h3>Register</h3>
              <p>Create your account as a buyer or seller with your detailed address information</p>
            </div>
            <div className="step-card">
              <div className="step-number">2</div>
              <h3>List or Browse</h3>
              <p>Sellers list products with videos, buyers browse through the video feed or catalog</p>
            </div>
            <div className="step-card">
              <div className="step-number">3</div>
              <h3>Connect & Chat</h3>
              <p>Use our chat system to negotiate prices and discuss product details</p>
            </div>
            <div className="step-card">
              <div className="step-number">4</div>
              <h3>Pay & Receive</h3>
              <p>Complete transactions using mobile money and enjoy fast delivery</p>
            </div>
          </div>
        </div>

        <div className="cta-section">
          <h2>Ready to Join IDUKA?</h2>
          <p>Start your journey in Rwanda's digital marketplace today</p>
          <div className="cta-buttons">
            <Link to="/register" className="btn btn-primary btn-large">
              Get Started Now
            </Link>
            <Link to="/products" className="btn btn-secondary btn-large">
              Browse Products
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
