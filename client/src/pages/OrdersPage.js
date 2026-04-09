import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from 'react-query';
import { FiPackage, FiMessageCircle, FiPhone, FiMapPin, FiCheck, FiTruck, FiClock, FiXCircle } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';

const OrdersPage = () => {
  const { user } = useAuth();
  const [statusFilter, setStatusFilter] = useState('all');

  const { data: ordersData, isLoading, error } = useQuery(
    'userOrders',
    async () => {
      const response = await axios.get('/api/payments/orders');
      return response.data.data;
    }
  );

  const orders = ordersData?.orders || [];

  const filteredOrders = orders.filter(order => {
    if (statusFilter === 'all') return true;
    return order.status === statusFilter;
  });

  const getStatusIcon = (status) => {
    switch (status) {
      case 'pending':
        return <FiClock className="status-icon pending" />;
      case 'confirmed':
        return <FiCheck className="status-icon confirmed" />;
      case 'shipped':
        return <FiTruck className="status-icon shipped" />;
      case 'delivered':
        return <FiCheck className="status-icon delivered" />;
      case 'cancelled':
        return <FiXCircle className="status-icon cancelled" />;
      default:
        return <FiPackage className="status-icon" />;
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending':
        return '#f39c12';
      case 'confirmed':
        return '#3498db';
      case 'shipped':
        return '#9b59b6';
      case 'delivered':
        return '#27ae60';
      case 'cancelled':
        return '#e74c3c';
      default:
        return '#95a5a6';
    }
  };

  const getPaymentStatusColor = (status) => {
    switch (status) {
      case 'paid':
        return '#27ae60';
      case 'pending':
        return '#f39c12';
      case 'failed':
        return '#e74c3c';
      case 'refunded':
        return '#9b59b6';
      default:
        return '#95a5a6';
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const formatPrice = (price) => {
    return `RWF ${price?.toLocaleString() || '0'}`;
  };

  if (!user) {
    return (
      <div className="orders-page">
        <div className="container">
          <div className="orders-empty">
            <h2>Please Login</h2>
            <p>You need to login to view your orders</p>
            <Link to="/login" className="btn btn-primary">
              Login to Continue
            </Link>
          </div>
        </div>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="orders-page">
        <div className="container">
          <div className="orders-loading">
            <div className="spinner"></div>
            <p>Loading orders...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="orders-page">
        <div className="container">
          <div className="orders-error">
            <h3>Error loading orders</h3>
            <p>Please try again later.</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="orders-page">
      <div className="container">
        <div className="orders-header">
          <h1>My Orders</h1>
          <p>Track and manage your orders</p>
        </div>

        {/* Status Filter */}
        <div className="orders-filter">
          <div className="filter-tabs">
            <button
              className={`filter-tab ${statusFilter === 'all' ? 'active' : ''}`}
              onClick={() => setStatusFilter('all')}
            >
              All Orders ({orders.length})
            </button>
            <button
              className={`filter-tab ${statusFilter === 'pending' ? 'active' : ''}`}
              onClick={() => setStatusFilter('pending')}
            >
              Pending
            </button>
            <button
              className={`filter-tab ${statusFilter === 'confirmed' ? 'active' : ''}`}
              onClick={() => setStatusFilter('confirmed')}
            >
              Confirmed
            </button>
            <button
              className={`filter-tab ${statusFilter === 'shipped' ? 'active' : ''}`}
              onClick={() => setStatusFilter('shipped')}
            >
              Shipped
            </button>
            <button
              className={`filter-tab ${statusFilter === 'delivered' ? 'active' : ''}`}
              onClick={() => setStatusFilter('delivered')}
            >
              Delivered
            </button>
            <button
              className={`filter-tab ${statusFilter === 'cancelled' ? 'active' : ''}`}
              onClick={() => setStatusFilter('cancelled')}
            >
              Cancelled
            </button>
          </div>
        </div>

        {/* Orders List */}
        {filteredOrders.length === 0 ? (
          <div className="orders-empty">
            <FiPackage className="empty-icon" />
            <h2>No orders found</h2>
            <p>
              {statusFilter === 'all' 
                ? "You haven't placed any orders yet." 
                : `No orders with status "${statusFilter}" found.`}
            </p>
            <Link to="/products" className="btn btn-primary">
              Start Shopping
            </Link>
          </div>
        ) : (
          <div className="orders-list">
            {filteredOrders.map((order) => (
              <div key={order.id} className="order-card">
                <div className="order-header">
                  <div className="order-info">
                    <h3>Order #{order.id.substring(0, 8).toUpperCase()}</h3>
                    <p className="order-date">{formatDate(order.created_at)}</p>
                  </div>
                  
                  <div className="order-statuses">
                    <div className="status-badge" style={{ color: getStatusColor(order.status) }}>
                      {getStatusIcon(order.status)}
                      <span>{order.status.charAt(0).toUpperCase() + order.status.slice(1)}</span>
                    </div>
                    
                    <div className="payment-status" style={{ color: getPaymentStatusColor(order.payment_status) }}>
                      <span className="payment-dot"></span>
                      <span>Payment: {order.payment_status.charAt(0).toUpperCase() + order.payment_status.slice(1)}</span>
                    </div>
                  </div>
                </div>

                <div className="order-content">
                  <div className="product-info">
                    <div className="product-image">
                      {order.product_images && order.product_images.length > 0 ? (
                        <img src={order.product_images[0]} alt={order.product_title} />
                      ) : (
                        <div className="image-placeholder">No Image</div>
                      )}
                    </div>
                    
                    <div className="product-details">
                      <h4>{order.product_title}</h4>
                      <p className="product-meta">
                        Category: {order.category} | Condition: {order.condition}
                      </p>
                      <div className="quantity-price">
                        <span>Quantity: {order.quantity}</span>
                        <span className="price">{formatPrice(order.total_price)}</span>
                      </div>
                    </div>
                  </div>

                  <div className="seller-info">
                    <h5>Seller Information</h5>
                    <p>
                      <strong>{order.seller_name}</strong>
                    </p>
                    <p className="seller-phone">
                      <FiPhone /> {order.seller_phone}
                    </p>
                  </div>

                  <div className="shipping-info">
                    <h5>Shipping Address</h5>
                    <div className="address-details">
                      {JSON.parse(order.shiping_address || '{}').street_address && (
                        <p>{JSON.parse(order.shiping_address || '{}').street_address}</p>
                      )}
                      <p>
                        {JSON.parse(order.shiping_address || '{}').village},{' '}
                        {JSON.parse(order.shiping_address || '{}').cell},{' '}
                        {JSON.parse(order.shiping_address || '{}').sector}
                      </p>
                      <p>
                        {JSON.parse(order.shiping_address || '{}').district},{' '}
                        {JSON.parse(order.shiping_address || '{}').province}
                      </p>
                      <p>{JSON.parse(order.shiping_address || '{}').country}</p>
                    </div>
                  </div>
                </div>

                <div className="order-actions">
                  <Link 
                    to={`/chat?order=${order.id}`}
                    className="btn btn-secondary"
                  >
                    <FiMessageCircle /> Contact Seller
                  </Link>
                  
                  {order.tracking_number && (
                    <button className="btn btn-outline">
                      <FiTruck /> Track Order
                    </button>
                  )}
                  
                  {order.status === 'pending' && (
                    <button className="btn btn-danger">
                      Cancel Order
                    </button>
                  )}
                  
                  {order.status === 'delivered' && (
                    <button className="btn btn-primary">
                      Leave Review
                    </button>
                  )}
                </div>

                {/* Order Timeline */}
                <div className="order-timeline">
                  <h5>Order Timeline</h5>
                  <div className="timeline">
                    <div className="timeline-item completed">
                      <div className="timeline-dot"></div>
                      <div className="timeline-content">
                        <p>Order Placed</p>
                        <span>{formatDate(order.created_at)}</span>
                      </div>
                    </div>
                    
                    {order.status !== 'pending' && (
                      <div className="timeline-item completed">
                        <div className="timeline-dot"></div>
                        <div className="timeline-content">
                          <p>Order Confirmed</p>
                          <span>Processing...</span>
                        </div>
                      </div>
                    )}
                    
                    {order.status === 'shipped' || order.status === 'delivered' ? (
                      <div className="timeline-item completed">
                        <div className="timeline-dot"></div>
                        <div className="timeline-content">
                          <p>Order Shipped</p>
                          <span>On the way</span>
                        </div>
                      </div>
                    ) : order.status !== 'pending' && order.status !== 'confirmed' ? (
                      <div className="timeline-item">
                        <div className="timeline-dot"></div>
                        <div className="timeline-content">
                          <p>Order Shipped</p>
                          <span>Pending</span>
                        </div>
                      </div>
                    ) : null}
                    
                    {order.status === 'delivered' ? (
                      <div className="timeline-item completed">
                        <div className="timeline-dot"></div>
                        <div className="timeline-content">
                          <p>Order Delivered</p>
                          <span>Completed</span>
                        </div>
                      </div>
                    ) : order.status !== 'cancelled' ? (
                      <div className="timeline-item">
                        <div className="timeline-dot"></div>
                        <div className="timeline-content">
                          <p>Order Delivered</p>
                          <span>Pending</span>
                        </div>
                      </div>
                    ) : null}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default OrdersPage;
