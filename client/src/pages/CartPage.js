import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { FiShoppingCart, FiTrash2, FiPlus, FiMinus, FiArrowLeft } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

const CartPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [cartItems, setCartItems] = useState([]);

  // Mock cart data - in production, this would come from backend/localStorage
  const mockCartItems = [
    {
      id: '1',
      title: 'Smartphone iPhone 12',
      price: 450000,
      quantity: 1,
      image: 'https://via.placeholder.com/100x100',
      seller: 'TechStore Rwanda',
      stock_quantity: 5
    },
    {
      id: '2',
      title: 'Laptop Dell Inspiron',
      price: 350000,
      quantity: 2,
      image: 'https://via.placeholder.com/100x100',
      seller: 'Computer World',
      stock_quantity: 3
    }
  ];

  React.useEffect(() => {
    // Load cart from localStorage or backend
    const savedCart = localStorage.getItem('cart');
    if (savedCart) {
      setCartItems(JSON.parse(savedCart));
    } else {
      setCartItems(mockCartItems);
    }
  }, []);

  const updateQuantity = (itemId, newQuantity) => {
    if (newQuantity < 1) return;
    
    setCartItems(prevItems => 
      prevItems.map(item => 
        item.id === itemId 
          ? { ...item, quantity: newQuantity }
          : item
      )
    );
  };

  const removeItem = (itemId) => {
    setCartItems(prevItems => prevItems.filter(item => item.id !== itemId));
  };

  const calculateSubtotal = () => {
    return cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
  };

  const calculateTotal = () => {
    const subtotal = calculateSubtotal();
    const shippingFee = subtotal > 0 ? 5000 : 0; // Flat shipping fee
    return subtotal + shippingFee;
  };

  const handleCheckout = () => {
    if (!user) {
      navigate('/login');
      return;
    }

    if (cartItems.length === 0) {
      alert('Your cart is empty');
      return;
    }

    // In production, this would proceed to checkout page
    navigate('/checkout');
  };

  if (!user) {
    return (
      <div className="cart-page">
        <div className="container">
          <div className="cart-empty">
            <h2>Please Login</h2>
            <p>You need to login to view your cart</p>
            <Link to="/login" className="btn btn-primary">
              Login to Continue
            </Link>
          </div>
        </div>
      </div>
    );
  }

  if (cartItems.length === 0) {
    return (
      <div className="cart-page">
        <div className="container">
          <div className="cart-empty">
            <FiShoppingCart className="empty-icon" />
            <h2>Your cart is empty</h2>
            <p>Add some products to get started!</p>
            <Link to="/products" className="btn btn-primary">
              Continue Shopping
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="cart-page">
      <div className="container">
        <div className="cart-header">
          <Link to="/products" className="back-btn">
            <FiArrowLeft /> Continue Shopping
          </Link>
          <h1>Shopping Cart ({cartItems.length} items)</h1>
        </div>

        <div className="cart-content">
          {/* Cart Items */}
          <div className="cart-items">
            {cartItems.map((item) => (
              <div key={item.id} className="cart-item">
                <div className="item-image">
                  <img src={item.image} alt={item.title} />
                </div>

                <div className="item-details">
                  <h3>{item.title}</h3>
                  <p className="seller">Sold by {item.seller}</p>
                  <p className="price">RWF {item.price.toLocaleString()}</p>
                  
                  {item.quantity > item.stock_quantity && (
                    <p className="stock-warning">
                      Only {item.stock_quantity} available in stock
                    </p>
                  )}
                </div>

                <div className="item-quantity">
                  <div className="quantity-controls">
                    <button
                      onClick={() => updateQuantity(item.id, item.quantity - 1)}
                      disabled={item.quantity <= 1}
                    >
                      <FiMinus />
                    </button>
                    <span>{item.quantity}</span>
                    <button
                      onClick={() => updateQuantity(item.id, item.quantity + 1)}
                      disabled={item.quantity >= item.stock_quantity}
                    >
                      <FiPlus />
                    </button>
                  </div>
                </div>

                <div className="item-total">
                  <p>RWF {(item.price * item.quantity).toLocaleString()}</p>
                </div>

                <div className="item-actions">
                  <button
                    onClick={() => removeItem(item.id)}
                    className="remove-btn"
                  >
                    <FiTrash2 />
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Cart Summary */}
          <div className="cart-summary">
            <h2>Order Summary</h2>
            
            <div className="summary-row">
              <span>Subtotal ({cartItems.length} items)</span>
              <span>RWF {calculateSubtotal().toLocaleString()}</span>
            </div>
            
            <div className="summary-row">
              <span>Shipping Fee</span>
              <span>RWF 5,000</span>
            </div>
            
            <div className="summary-row total">
              <span>Total</span>
              <span>RWF {calculateTotal().toLocaleString()}</span>
            </div>

            <div className="promo-section">
              <input
                type="text"
                placeholder="Enter promo code"
                className="promo-input"
              />
              <button className="btn btn-secondary">Apply</button>
            </div>

            <button
              onClick={handleCheckout}
              className="btn btn-primary checkout-btn"
            >
              Proceed to Checkout
            </button>

            <div className="security-info">
              <p>
                <span className="secure-icon">Secure Checkout</span>
                Your payment information is encrypted and secure
              </p>
            </div>

            <div className="payment-methods">
              <h4>Accepted Payment Methods</h4>
              <div className="payment-icons">
                <span className="payment-method">MTN MoMo</span>
                <span className="payment-method">Airtel Money</span>
              </div>
            </div>
          </div>
        </div>

        {/* Recommendations */}
        <div className="recommendations">
          <h2>You might also like</h2>
          <div className="recommendation-grid">
            {/* Mock recommendations */}
            {[1, 2, 3, 4].map((item) => (
              <div key={item} className="recommendation-card">
                <div className="rec-image">
                  <img src={`https://via.placeholder.com/150x150?text=Product${item}`} alt={`Product ${item}`} />
                </div>
                <h4>Recommended Product {item}</h4>
                <p className="rec-price">RWF {(Math.random() * 100000 + 50000).toLocaleString()}</p>
                <button className="btn btn-secondary">Add to Cart</button>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CartPage;
