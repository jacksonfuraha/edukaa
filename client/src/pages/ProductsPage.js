import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from 'react-query';
import { FiSearch, FiFilter, FiHeart, FiMessageCircle, FiShoppingCart, FiStar } from 'react-icons/fi';
import axios from 'axios';

const ProductsPage = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [filters, setFilters] = useState({
    category: '',
    minPrice: '',
    maxPrice: '',
    condition: '',
    sort: 'created_at',
    order: 'DESC'
  });
  const [showFilters, setShowFilters] = useState(false);
  const [favorites, setFavorites] = useState(new Set());

  const categories = [
    'Electronics', 'Clothing', 'Food', 'Furniture', 'Books', 
    'Sports', 'Beauty', 'Toys', 'Health', 'Other'
  ];

  const { data: productsData, isLoading, error } = useQuery(
    ['products', searchTerm, filters],
    async () => {
      const params = new URLSearchParams();
      
      if (searchTerm) params.append('search', searchTerm);
      if (filters.category) params.append('category', filters.category);
      if (filters.minPrice) params.append('min_price', filters.minPrice);
      if (filters.maxPrice) params.append('max_price', filters.maxPrice);
      if (filters.condition) params.append('condition', filters.condition);
      if (filters.sort) params.append('sort', filters.sort);
      if (filters.order) params.append('order', filters.order);

      const response = await axios.get(`/api/products?${params.toString()}`);
      return response.data.data;
    },
    {
      keepPreviousData: true,
      staleTime: 2 * 60 * 1000, // 2 minutes
    }
  );

  const handleSearch = (e) => {
    e.preventDefault();
    // Search is handled by the query dependency
  };

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({
      ...prev,
      [key]: value
    }));
  };

  const clearFilters = () => {
    setFilters({
      category: '',
      minPrice: '',
      maxPrice: '',
      condition: '',
      sort: 'created_at',
      order: 'DESC'
    });
  };

  const toggleFavorite = async (productId) => {
    try {
      if (favorites.has(productId)) {
        await axios.delete(`/api/users/favorites/${productId}`);
        setFavorites(prev => {
          const newSet = new Set(prev);
          newSet.delete(productId);
          return newSet;
        });
      } else {
        await axios.post('/api/users/favorites', { product_id: productId });
        setFavorites(prev => new Set(prev).add(productId));
      }
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  };

  const renderStars = (rating) => {
    const stars = [];
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 !== 0;

    for (let i = 0; i < fullStars; i++) {
      stars.push(<FiStar key={i} className="star filled" />);
    }
    if (hasHalfStar) {
      stars.push(<FiStar key="half" className="star half" />);
    }
    for (let i = stars.length; i < 5; i++) {
      stars.push(<FiStar key={i} className="star empty" />);
    }

    return stars;
  };

  const products = productsData?.products || [];

  if (error) {
    return (
      <div className="error-container">
        <h3>Error loading products</h3>
        <p>Please try again later.</p>
      </div>
    );
  }

  return (
    <div className="products-page">
      <div className="container">
        {/* Header */}
        <div className="products-header">
          <h1>Browse Products</h1>
          <p>Discover amazing products from local sellers across Rwanda</p>
        </div>

        {/* Search and Filters */}
        <div className="products-controls">
          <form onSubmit={handleSearch} className="search-form">
            <div className="search-input-group">
              <FiSearch className="search-icon" />
              <input
                type="text"
                placeholder="Search products..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="search-input"
              />
              <button type="submit" className="search-btn">Search</button>
            </div>
          </form>

          <div className="filter-controls">
            <button 
              className={`filter-toggle ${showFilters ? 'active' : ''}`}
              onClick={() => setShowFilters(!showFilters)}
            >
              <FiFilter /> Filters
            </button>
          </div>
        </div>

        {/* Filter Panel */}
        {showFilters && (
          <div className="filter-panel">
            <div className="filter-grid">
              <div className="filter-group">
                <label>Category</label>
                <select
                  value={filters.category}
                  onChange={(e) => handleFilterChange('category', e.target.value)}
                  className="filter-select"
                >
                  <option value="">All Categories</option>
                  {categories.map(category => (
                    <option key={category} value={category}>{category}</option>
                  ))}
                </select>
              </div>

              <div className="filter-group">
                <label>Min Price</label>
                <input
                  type="number"
                  placeholder="0"
                  value={filters.minPrice}
                  onChange={(e) => handleFilterChange('minPrice', e.target.value)}
                  className="filter-input"
                />
              </div>

              <div className="filter-group">
                <label>Max Price</label>
                <input
                  type="number"
                  placeholder="1000000"
                  value={filters.maxPrice}
                  onChange={(e) => handleFilterChange('maxPrice', e.target.value)}
                  className="filter-input"
                />
              </div>

              <div className="filter-group">
                <label>Condition</label>
                <select
                  value={filters.condition}
                  onChange={(e) => handleFilterChange('condition', e.target.value)}
                  className="filter-select"
                >
                  <option value="">All Conditions</option>
                  <option value="new">New</option>
                  <option value="used">Used</option>
                  <option value="refurbished">Refurbished</option>
                </select>
              </div>

              <div className="filter-group">
                <label>Sort By</label>
                <select
                  value={filters.sort}
                  onChange={(e) => handleFilterChange('sort', e.target.value)}
                  className="filter-select"
                >
                  <option value="created_at">Latest</option>
                  <option value="price">Price</option>
                  <option value="views">Popularity</option>
                  <option value="average_rating">Rating</option>
                </select>
              </div>

              <div className="filter-group">
                <label>Order</label>
                <select
                  value={filters.order}
                  onChange={(e) => handleFilterChange('order', e.target.value)}
                  className="filter-select"
                >
                  <option value="DESC">Descending</option>
                  <option value="ASC">Ascending</option>
                </select>
              </div>
            </div>

            <div className="filter-actions">
              <button onClick={clearFilters} className="btn btn-secondary">
                Clear Filters
              </button>
            </div>
          </div>
        )}

        {/* Results Count */}
        <div className="products-results">
          <p>
            {isLoading ? 'Loading...' : `Found ${products.length} products`}
          </p>
        </div>

        {/* Products Grid */}
        {isLoading ? (
          <div className="products-loading">
            <div className="spinner"></div>
            <p>Loading products...</p>
          </div>
        ) : products.length === 0 ? (
          <div className="products-empty">
            <h3>No products found</h3>
            <p>Try adjusting your search or filters</p>
          </div>
        ) : (
          <div className="products-grid">
            {products.map((product) => (
              <div key={product.id} className="product-card">
                <div className="product-image-container">
                  {product.images && product.images.length > 0 ? (
                    <img 
                      src={product.images[0]} 
                      alt={product.title}
                      className="product-image"
                    />
                  ) : (
                    <div className="product-image-placeholder">
                      No Image
                    </div>
                  )}
                  <button 
                    className={`favorite-btn ${favorites.has(product.id) ? 'favorited' : ''}`}
                    onClick={() => toggleFavorite(product.id)}
                  >
                    <FiHeart />
                  </button>
                </div>

                <div className="product-info">
                  <Link to={`/products/${product.id}`} className="product-title">
                    {product.title}
                  </Link>
                  
                  <div className="product-price">
                    RWF {product.price?.toLocaleString()}
                  </div>

                  <div className="product-meta">
                    <span className="product-seller">
                      {product.seller_name}
                    </span>
                    <span className="product-condition">
                      {product.condition}
                    </span>
                  </div>

                  <div className="product-rating">
                    <div className="stars">
                      {renderStars(product.average_rating)}
                    </div>
                    <span className="rating-text">
                      {product.average_rating > 0 ? `${product.average_rating.toFixed(1)} (${product.review_count})` : 'No reviews'}
                    </span>
                  </div>

                  <div className="product-stats">
                    <span className="views">{product.views} views</span>
                    {product.stock_quantity <= 5 && (
                      <span className="low-stock">Only {product.stock_quantity} left</span>
                    )}
                  </div>
                </div>

                <div className="product-actions">
                  <button className="action-btn chat-btn">
                    <FiMessageCircle />
                  </button>
                  <button className="action-btn cart-btn">
                    <FiShoppingCart />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ProductsPage;
