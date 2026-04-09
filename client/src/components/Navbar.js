import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { FiShoppingCart, FiMessageCircle, FiVideo, FiUser, FiLogOut, FiMenu, FiX, FiHome, FiPackage } from 'react-icons/fi';

const Navbar = () => {
  const { user, isAuthenticated, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate('/');
    setIsMobileMenuOpen(false);
  };

  const navLinks = [
    { path: '/', label: 'Home', icon: FiHome },
    { path: '/products', label: 'Products', icon: FiPackage },
    { path: '/videos', label: 'Video Feed', icon: FiVideo },
  ];

  const userLinks = [
    { path: '/chat', label: 'Messages', icon: FiMessageCircle },
    { path: '/cart', label: 'Cart', icon: FiShoppingCart },
    { path: '/profile', label: 'Profile', icon: FiUser },
  ];

  const isActiveLink = (path) => {
    return location.pathname === path || (path !== '/' && location.pathname.startsWith(path));
  };

  return (
    <nav className="navbar">
      <div className="container">
        <div className="navbar-content">
          <Link to="/" className="navbar-logo">
            <span className="logo-text">IDUKA</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="navbar-nav desktop-nav">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                className={`nav-link ${isActiveLink(link.path) ? 'active' : ''}`}
              >
                <link.icon className="nav-icon" />
                <span>{link.label}</span>
              </Link>
            ))}
          </div>

          {/* User Actions */}
          <div className="navbar-actions desktop-actions">
            {isAuthenticated ? (
              <div className="user-menu">
                <div className="user-info">
                  <span className="user-name">{user?.full_name || user?.username}</span>
                  <span className="user-type">{user?.user_type}</span>
                </div>
                <div className="user-links">
                  {userLinks.map((link) => (
                    <Link
                      key={link.path}
                      to={link.path}
                      className={`user-link ${isActiveLink(link.path) ? 'active' : ''}`}
                    >
                      <link.icon className="nav-icon" />
                    </Link>
                  ))}
                  {user?.user_type === 'seller' && (
                    <Link
                      to="/dashboard"
                      className={`user-link ${isActiveLink('/dashboard') ? 'active' : ''}`}
                    >
                      <FiPackage className="nav-icon" />
                    </Link>
                  )}
                  <button onClick={handleLogout} className="logout-btn">
                    <FiLogOut className="nav-icon" />
                  </button>
                </div>
              </div>
            ) : (
              <div className="auth-links">
                <Link to="/login" className="btn btn-secondary">
                  Login
                </Link>
                <Link to="/register" className="btn btn-primary">
                  Register
                </Link>
              </div>
            )}
          </div>

          {/* Mobile Menu Toggle */}
          <button
            className="mobile-menu-toggle"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            {isMobileMenuOpen ? <FiX /> : <FiMenu />}
          </button>
        </div>

        {/* Mobile Navigation */}
        <div className={`mobile-nav ${isMobileMenuOpen ? 'open' : ''}`}>
          <div className="mobile-nav-content">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                className={`mobile-nav-link ${isActiveLink(link.path) ? 'active' : ''}`}
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <link.icon className="nav-icon" />
                <span>{link.label}</span>
              </Link>
            ))}
            
            {isAuthenticated && (
              <>
                <div className="mobile-user-info">
                  <span className="user-name">{user?.full_name || user?.username}</span>
                  <span className="user-type">{user?.user_type}</span>
                </div>
                {userLinks.map((link) => (
                  <Link
                    key={link.path}
                    to={link.path}
                    className={`mobile-nav-link ${isActiveLink(link.path) ? 'active' : ''}`}
                    onClick={() => setIsMobileMenuOpen(false)}
                  >
                    <link.icon className="nav-icon" />
                    <span>{link.label}</span>
                  </Link>
                ))}
                {user?.user_type === 'seller' && (
                  <Link
                    to="/dashboard"
                    className={`mobile-nav-link ${isActiveLink('/dashboard') ? 'active' : ''}`}
                    onClick={() => setIsMobileMenuOpen(false)}
                  >
                    <FiPackage className="nav-icon" />
                    <span>Dashboard</span>
                  </Link>
                )}
                <button
                  onClick={handleLogout}
                  className="mobile-logout-btn"
                >
                  <FiLogOut className="nav-icon" />
                  <span>Logout</span>
                </button>
              </>
            )}
            
            {!isAuthenticated && (
              <div className="mobile-auth-links">
                <Link
                  to="/login"
                  className="btn btn-secondary"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Login
                </Link>
                <Link
                  to="/register"
                  className="btn btn-primary"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Register
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
