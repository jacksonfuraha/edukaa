import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from 'react-query';
import { FiPackage, FiPlus, FiEdit2, FiTrash2, FiEye, FiMessageCircle, FiTrendingUp, FiUsers, FiDollarSign } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';

const SellerDashboard = () => {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('products');
  const [statusFilter, setStatusFilter] = useState('all');

  // Fetch seller's products
  const { data: productsData, isLoading: productsLoading } = useQuery(
    'sellerProducts',
    async () => {
      const response = await axios.get('/api/products/seller/me');
      return response.data.data;
    }
  );

  // Fetch seller's orders
  const { data: ordersData, isLoading: ordersLoading } = useQuery(
    'sellerOrders',
    async () => {
      const response = await axios.get('/api/payments/orders');
      return response.data.data;
    }
  );

  // Fetch seller's statistics
  const { data: statsData, isLoading: statsLoading } = useQuery(
    'sellerStats',
    async () => {
      // Mock stats for now - would be implemented in backend
      return {
        totalProducts: productsData?.products?.length || 0,
        totalOrders: ordersData?.orders?.length || 0,
        totalRevenue: 0,
        totalViews: productsData?.products?.reduce((sum, p) => sum + (p.views || 0), 0) || 0,
        averageRating: 0
      };
    },
    {
      enabled: !productsLoading && !ordersLoading
    }
  );

  const products = productsData?.products || [];
  const orders = ordersData?.orders || [];
  const stats = statsData || {};

  const filteredProducts = products.filter(product => {
    if (statusFilter === 'active') return product.is_active;
    if (statusFilter === 'inactive') return !product.is_active;
    return true;
  });

  const handleDeleteProduct = async (productId) => {
    if (window.confirm('Are you sure you want to delete this product?')) {
      try {
        await axios.delete(`/api/products/${productId}`);
        // Refresh products
        window.location.reload();
      } catch (error) {
        console.error('Failed to delete product:', error);
        alert('Failed to delete product');
      }
    }
  };

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const formatPrice = (price) => {
    return `RWF ${price?.toLocaleString() || '0'}`;
  };

  if (productsLoading || ordersLoading) {
    return (
      <div className="dashboard-loading">
        <div className="spinner"></div>
        <p>Loading dashboard...</p>
      </div>
    );
  }

  return (
    <div className="seller-dashboard">
      <div className="container">
        <div className="dashboard-header">
          <h1>Seller Dashboard</h1>
          <p>Manage your products and orders</p>
        </div>

        {/* Stats Overview */}
        <div className="stats-overview">
          <div className="stat-card">
            <div className="stat-icon">
              <FiPackage />
            </div>
            <div className="stat-info">
              <h3>{stats.totalProducts}</h3>
              <p>Total Products</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <FiUsers />
            </div>
            <div className="stat-info">
              <h3>{stats.totalOrders}</h3>
              <p>Total Orders</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <FiDollarSign />
            </div>
            <div className="stat-info">
              <h3>{formatPrice(stats.totalRevenue)}</h3>
              <p>Total Revenue</p>
            </div>
          </div>
          <div className="stat-card">
            <div className="stat-icon">
              <FiTrendingUp />
            </div>
            <div className="stat-info">
              <h3>{stats.totalViews}</h3>
              <p>Total Views</p>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="quick-actions">
          <Link to="/products/new" className="action-card">
            <FiPlus />
            <h3>Add New Product</h3>
            <p>List a new product for sale</p>
          </Link>
          <Link to="/videos/upload" className="action-card">
            <FiPackage />
            <h3>Upload Video</h3>
            <p>Add product video advertisement</p>
          </Link>
          <Link to="/chat" className="action-card">
            <FiMessageCircle />
            <h3>Messages</h3>
            <p>View customer messages</p>
          </Link>
        </div>

        {/* Tabs */}
        <div className="dashboard-tabs">
          <button
            className={`tab-btn ${activeTab === 'products' ? 'active' : ''}`}
            onClick={() => setActiveTab('products')}
          >
            Products
          </button>
          <button
            className={`tab-btn ${activeTab === 'orders' ? 'active' : ''}`}
            onClick={() => setActiveTab('orders')}
          >
            Orders
          </button>
        </div>

        {/* Tab Content */}
        <div className="tab-content">
          {activeTab === 'products' && (
            <div className="products-tab">
              <div className="tab-header">
                <h3>My Products</h3>
                <div className="filter-controls">
                  <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="filter-select"
                  >
                    <option value="all">All Products</option>
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                  </select>
                </div>
              </div>

              {filteredProducts.length === 0 ? (
                <div className="empty-state">
                  <h3>No products found</h3>
                  <p>
                    {statusFilter === 'all' 
                      ? "You haven't listed any products yet." 
                      : `No ${statusFilter} products found.`}
                  </p>
                  <Link to="/products/new" className="btn btn-primary">
                    Add Your First Product
                  </Link>
                </div>
              ) : (
                <div className="products-grid">
                  {filteredProducts.map((product) => (
                    <div key={product.id} className="product-card">
                      <div className="product-image">
                        {product.images && product.images.length > 0 ? (
                          <img src={product.images[0]} alt={product.title} />
                        ) : (
                          <div className="image-placeholder">No Image</div>
                        )}
                        <div className={`status-badge ${product.is_active ? 'active' : 'inactive'}`}>
                          {product.is_active ? 'Active' : 'Inactive'}
                        </div>
                      </div>
                      
                      <div className="product-info">
                        <h4>{product.title}</h4>
                        <p className="price">{formatPrice(product.price)}</p>
                        <p className="category">{product.category}</p>
                        <p className="stock">Stock: {product.stock_quantity}</p>
                        <p className="views">{product.views || 0} views</p>
                      </div>

                      <div className="product-actions">
                        <Link 
                          to={`/products/${product.id}`} 
                          className="action-btn view-btn"
                        >
                          <FiEye />
                        </Link>
                        <Link 
                          to={`/products/${product.id}/edit`} 
                          className="action-btn edit-btn"
                        >
                          <FiEdit2 />
                        </Link>
                        <button
                          onClick={() => handleDeleteProduct(product.id)}
                          className="action-btn delete-btn"
                        >
                          <FiTrash2 />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {activeTab === 'orders' && (
            <div className="orders-tab">
              <div className="tab-header">
                <h3>Recent Orders</h3>
              </div>

              {orders.length === 0 ? (
                <div className="empty-state">
                  <h3>No orders yet</h3>
                  <p>When customers place orders, they'll appear here.</p>
                </div>
              ) : (
                <div className="orders-list">
                  {orders.map((order) => (
                    <div key={order.id} className="order-card">
                      <div className="order-header">
                        <div className="order-info">
                          <h4>Order #{order.id.substring(0, 8)}</h4>
                          <p className="date">{formatDate(order.created_at)}</p>
                        </div>
                        <div className="order-status">
                          <span className={`status-badge ${order.status}`}>
                            {order.status}
                          </span>
                          <span className={`payment-status ${order.payment_status}`}>
                            {order.payment_status}
                          </span>
                        </div>
                      </div>

                      <div className="order-details">
                        <div className="product-info">
                          <h5>{order.product_title}</h5>
                          <p>Quantity: {order.quantity}</p>
                          <p className="price">{formatPrice(order.total_price)}</p>
                        </div>
                        
                        <div className="buyer-info">
                          <p><strong>Buyer:</strong> {order.buyer_name}</p>
                          <p><strong>Phone:</strong> {order.buyer_phone}</p>
                        </div>
                      </div>

                      <div className="order-actions">
                        <Link to={`/chat?order=${order.id}`} className="btn btn-secondary">
                          <FiMessageCircle /> Contact Buyer
                        </Link>
                        {order.status === 'pending' && (
                          <button className="btn btn-primary">
                            Confirm Order
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default SellerDashboard;
