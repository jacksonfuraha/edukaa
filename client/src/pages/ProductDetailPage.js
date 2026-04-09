import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { FiHeart, FiMessageCircle, FiShoppingCart, FiShare2, FiStar, FiMapPin, FiPhone, FiUser } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import toast from 'react-toastify';

const ProductDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const [quantity, setQuantity] = useState(1);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);
  const [isFavorited, setIsFavorited] = useState(false);
  const queryClient = useQueryClient();

  // Fetch product details
  const { data: productData, isLoading, error } = useQuery(
    ['product', id],
    async () => {
      const response = await axios.get(`/api/products/${id}`);
      return response.data.data;
    }
  );

  // Create order mutation
  const createOrderMutation = useMutation(
    async (orderData) => {
      const response = await axios.post('/api/payments/order', orderData);
      return response.data.data;
    },
    {
      onSuccess: (data) => {
        toast.success('Order created successfully!');
        navigate(`/orders/${data.order.id}`);
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to create order');
      }
    }
  );

  // Add to favorites mutation
  const toggleFavoriteMutation = useMutation(
    async () => {
      if (isFavorited) {
        await axios.delete(`/api/users/favorites/${id}`);
      } else {
        await axios.post('/api/users/favorites', { product_id: id });
      }
    },
    {
      onSuccess: () => {
        setIsFavorited(!isFavorited);
        toast.success(isFavorited ? 'Removed from favorites' : 'Added to favorites');
      },
      onError: (error) => {
        toast.error('Failed to update favorites');
      }
    }
  );

  const product = productData?.product;
  const reviews = productData?.reviews || [];
  const videos = productData?.videos || [];

  const handleBuyNow = () => {
    if (!user) {
      navigate('/login');
      return;
    }

    if (user?.id === product?.seller_id) {
      toast.error('You cannot buy your own product');
      return;
    }

    // For demo, we'll use a default address - in production, user would select address
    const orderData = {
      product_id: id,
      quantity: quantity,
      shipping_address: {
        country: 'Rwanda',
        province: 'Kigali',
        district: 'Nyarugenge',
        sector: 'Nyabugogo',
        cell: 'Kigali',
        village: 'Kigali City',
        street_address: 'Default address'
      }
    };

    createOrderMutation.mutate(orderData);
  };

  const handleChat = () => {
    if (!user) {
      navigate('/login');
      return;
    }

    // Create chat or navigate to existing chat
    navigate(`/chat?product=${id}`);
  };

  const handleShare = () => {
    if (navigator.share) {
      navigator.share({
        title: product?.title,
        text: `Check out this product on IDUKA: ${product?.title}`,
        url: window.location.href
      });
    } else {
      navigator.clipboard.writeText(window.location.href);
      toast.success('Link copied to clipboard!');
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

  if (isLoading) {
    return (
      <div className="product-detail-loading">
        <div className="spinner"></div>
        <p>Loading product details...</p>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="product-detail-error">
        <h3>Product not found</h3>
        <p>The product you're looking for doesn't exist or has been removed.</p>
        <button onClick={() => navigate('/products')} className="btn btn-primary">
          Back to Products
        </button>
      </div>
    );
  }

  const images = product.images || [];
  const currentImage = images[selectedImageIndex] || null;

  return (
    <div className="product-detail-page">
      <div className="container">
        <div className="product-detail-content">
          {/* Product Images */}
          <div className="product-images">
            <div className="main-image">
              {currentImage ? (
                <img src={currentImage} alt={product.title} />
              ) : (
                <div className="image-placeholder">
                  <span>No Image Available</span>
                </div>
              )}
            </div>
            
            {images.length > 1 && (
              <div className="image-thumbnails">
                {images.map((image, index) => (
                  <button
                    key={index}
                    className={`thumbnail ${index === selectedImageIndex ? 'active' : ''}`}
                    onClick={() => setSelectedImageIndex(index)}
                  >
                    <img src={image} alt={`${product.title} ${index + 1}`} />
                  </button>
                ))}
              </div>
            )}

            {/* Product Videos */}
            {videos.length > 0 && (
              <div className="product-videos">
                <h4>Product Videos</h4>
                <div className="video-grid">
                  {videos.map((video) => (
                    <div key={video.id} className="video-thumbnail">
                      <video controls>
                        <source src={video.video_url} type="video/mp4" />
                      </video>
                      <p>{video.caption}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Product Information */}
          <div className="product-info">
            <div className="product-header">
              <h1>{product.title}</h1>
              <div className="product-meta">
                <span className="category">{product.category}</span>
                <span className={`condition ${product.condition}`}>
                  {product.condition}
                </span>
              </div>
            </div>

            <div className="product-price-section">
              <div className="price">
                RWF {product.price?.toLocaleString()}
              </div>
              <div className="stock-info">
                {product.stock_quantity > 0 ? (
                  <span className="in-stock">
                    {product.stock_quantity} items available
                  </span>
                ) : (
                  <span className="out-of-stock">Out of stock</span>
                )}
              </div>
            </div>

            {/* Rating and Reviews */}
            <div className="product-rating">
              <div className="stars">
                {renderStars(product.average_rating)}
              </div>
              <span className="rating-text">
                {product.average_rating > 0 
                  ? `${product.average_rating.toFixed(1)} (${product.review_count} reviews)`
                  : 'No reviews yet'
                }
              </span>
            </div>

            {/* Product Description */}
            <div className="product-description">
              <h3>Description</h3>
              <p>{product.description}</p>
            </div>

            {/* Seller Information */}
            <div className="seller-info">
              <h3>Seller Information</h3>
              <div className="seller-card">
                <div className="seller-avatar">
                  <FiUser />
                </div>
                <div className="seller-details">
                  <h4>{product.seller_full_name}</h4>
                  <p>@{product.seller_name}</p>
                  <div className="seller-rating">
                    {renderStars(product.average_rating)}
                    <span>{product.average_rating.toFixed(1)}</span>
                  </div>
                </div>
                <div className="seller-actions">
                  <button className="btn btn-secondary" onClick={handleChat}>
                    <FiMessageCircle /> Contact
                  </button>
                </div>
              </div>
            </div>

            {/* Purchase Actions */}
            {product.stock_quantity > 0 && (
              <div className="purchase-actions">
                <div className="quantity-selector">
                  <label>Quantity:</label>
                  <div className="quantity-controls">
                    <button
                      onClick={() => setQuantity(Math.max(1, quantity - 1))}
                      disabled={quantity <= 1}
                    >
                      -
                    </button>
                    <input
                      type="number"
                      value={quantity}
                      onChange={(e) => setQuantity(Math.max(1, Math.min(product.stock_quantity, parseInt(e.target.value) || 1)))}
                      min="1"
                      max={product.stock_quantity}
                    />
                    <button
                      onClick={() => setQuantity(Math.min(product.stock_quantity, quantity + 1))}
                      disabled={quantity >= product.stock_quantity}
                    >
                      +
                    </button>
                  </div>
                </div>

                <div className="action-buttons">
                  <button
                    className="btn btn-primary buy-btn"
                    onClick={handleBuyNow}
                    disabled={createOrderMutation.isLoading}
                  >
                    {createOrderMutation.isLoading ? 'Processing...' : 'Buy Now'}
                  </button>
                  
                  <div className="secondary-actions">
                    <button
                      className="action-btn"
                      onClick={() => toggleFavoriteMutation.mutate()}
                      disabled={toggleFavoriteMutation.isLoading}
                    >
                      <FiHeart className={isFavorited ? 'favorited' : ''} />
                    </button>
                    <button className="action-btn" onClick={handleShare}>
                      <FiShare2 />
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* Product Stats */}
            <div className="product-stats">
              <div className="stat-item">
                <span className="stat-value">{product.views || 0}</span>
                <span className="stat-label">Views</span>
              </div>
              <div className="stat-item">
                <span className="stat-value">{product.review_count}</span>
                <span className="stat-label">Reviews</span>
              </div>
              <div className="stat-item">
                <span className="stat-value">{product.stock_quantity}</span>
                <span className="stat-label">In Stock</span>
              </div>
            </div>
          </div>
        </div>

        {/* Reviews Section */}
        <div className="reviews-section">
          <h2>Customer Reviews</h2>
          {reviews.length === 0 ? (
            <div className="no-reviews">
              <p>No reviews yet. Be the first to review this product!</p>
            </div>
          ) : (
            <div className="reviews-list">
              {reviews.map((review) => (
                <div key={review.id} className="review-card">
                  <div className="review-header">
                    <div className="reviewer-info">
                      <h4>{review.reviewer_name}</h4>
                      <div className="review-rating">
                        {renderStars(review.rating)}
                      </div>
                    </div>
                    <div className="review-date">
                      {new Date(review.created_at).toLocaleDateString()}
                    </div>
                  </div>
                  <div className="review-content">
                    <p>{review.review_text}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ProductDetailPage;
