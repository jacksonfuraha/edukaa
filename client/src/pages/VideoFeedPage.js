import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from 'react-query';
import { FiHeart, FiMessageCircle, FiShare2, FiPlay, FiPause, FiVolume2, FiVolumeX } from 'react-icons/fi';
import axios from 'axios';

const VideoFeedPage = () => {
  const [currentVideoIndex, setCurrentVideoIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const [likedVideos, setLikedVideos] = useState(new Set());
  const videoRefs = useRef([]);
  const containerRef = useRef(null);
  const navigate = useNavigate();
  const { category } = useParams();

  const { data: videosData, isLoading, error } = useQuery(
    ['videos', category],
    async () => {
      const url = category ? `/api/videos/feed?category=${category}` : '/api/videos/feed';
      const response = await axios.get(url);
      return response.data.data;
    },
    {
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000, // 5 minutes
    }
  );

  const videos = videosData?.videos || [];

  const handleScroll = useCallback(() => {
    if (!containerRef.current || videos.length === 0) return;

    const container = containerRef.current;
    const scrollTop = container.scrollTop;
    const containerHeight = container.clientHeight;
    const videoHeight = containerHeight;

    const newIndex = Math.round(scrollTop / videoHeight);
    
    if (newIndex !== currentVideoIndex && newIndex >= 0 && newIndex < videos.length) {
      setCurrentVideoIndex(newIndex);
      setIsPlaying(true);
    }
  }, [currentVideoIndex, videos.length]);

  useEffect(() => {
    const container = containerRef.current;
    if (container) {
      container.addEventListener('scroll', handleScroll);
      return () => container.removeEventListener('scroll', handleScroll);
    }
  }, [handleScroll]);

  useEffect(() => {
    // Auto-play current video
    if (videoRefs.current[currentVideoIndex]) {
      const currentVideo = videoRefs.current[currentVideoIndex];
      if (isPlaying) {
        currentVideo.play().catch(err => console.log('Auto-play failed:', err));
      } else {
        currentVideo.pause();
      }
    }

    // Pause other videos
    videoRefs.current.forEach((video, index) => {
      if (video && index !== currentVideoIndex) {
        video.pause();
      }
    });
  }, [currentVideoIndex, isPlaying]);

  const handleVideoClick = () => {
    setIsPlaying(!isPlaying);
  };

  const handleVolumeToggle = () => {
    setIsMuted(!isMuted);
    if (videoRefs.current[currentVideoIndex]) {
      videoRefs.current[currentVideoIndex].muted = !isMuted;
    }
  };

  const handleLike = async (videoId) => {
    try {
      await axios.post(`/api/videos/${videoId}/like`);
      setLikedVideos(prev => new Set(prev).add(videoId));
    } catch (error) {
      console.error('Failed to like video:', error);
    }
  };

  const handleChat = (productId) => {
    navigate(`/chat?product=${productId}`);
  };

  const handleShare = (video) => {
    if (navigator.share) {
      navigator.share({
        title: video.title,
        text: `Check out this product on IDUKA: ${video.title}`,
        url: window.location.href
      });
    } else {
      // Fallback - copy to clipboard
      navigator.clipboard.writeText(window.location.href);
      alert('Link copied to clipboard!');
    }
  };

  const scrollToVideo = (index) => {
    if (containerRef.current) {
      const container = containerRef.current;
      const videoHeight = container.clientHeight;
      container.scrollTo({
        top: index * videoHeight,
        behavior: 'smooth'
      });
    }
  };

  if (isLoading) {
    return (
      <div className="video-feed-loading">
        <div className="spinner"></div>
        <p>Loading video feed...</p>
      </div>
    );
  }

  if (error || videos.length === 0) {
    return (
      <div className="video-feed-empty">
        <h3>No videos available</h3>
        <p>Check back later for new product videos!</p>
      </div>
    );
  }

  const currentVideo = videos[currentVideoIndex];

  return (
    <div className="video-feed-container" ref={containerRef}>
      {videos.map((video, index) => (
        <div key={video.id} className="video-slide">
          <video
            ref={el => videoRefs.current[index] = el}
            className="video-player"
            src={video.video_url}
            loop
            muted={isMuted}
            playsInline
            onClick={handleVideoClick}
            style={{
              opacity: index === currentVideoIndex ? 1 : 0.3,
              transform: index === currentVideoIndex ? 'scale(1)' : 'scale(0.95)'
            }}
          />
          
          {index === currentVideoIndex && (
            <div className="video-overlay">
              <div className="video-info">
                <h3>{video.title}</h3>
                <p className="video-price">RWF {video.price?.toLocaleString()}</p>
                <p className="video-seller">@{video.seller_name}</p>
                <p className="video-caption">{video.caption}</p>
              </div>

              <div className="video-actions">
                <button
                  className={`video-action-btn ${likedVideos.has(video.id) ? 'liked' : ''}`}
                  onClick={() => handleLike(video.id)}
                >
                  <FiHeart />
                  <span>Like</span>
                </button>

                <button
                  className="video-action-btn"
                  onClick={() => handleChat(video.product_id)}
                >
                  <FiMessageCircle />
                  <span>Chat</span>
                </button>

                <button
                  className="video-action-btn"
                  onClick={() => handleShare(video)}
                >
                  <FiShare2 />
                  <span>Share</span>
                </button>

                <button
                  className="video-action-btn"
                  onClick={() => navigate(`/products/${video.product_id}`)}
                >
                  <FiPlay />
                  <span>View</span>
                </button>
              </div>

              <div className="video-controls">
                <button
                  className="control-btn"
                  onClick={handleVideoClick}
                >
                  {isPlaying ? <FiPause /> : <FiPlay />}
                </button>
                <button
                  className="control-btn"
                  onClick={handleVolumeToggle}
                >
                  {isMuted ? <FiVolumeX /> : <FiVolume2 />}
                </button>
              </div>

              <div className="video-progress">
                <div className="progress-bar">
                  <div 
                    className="progress-fill"
                    style={{ width: '35%' }}
                  />
                </div>
              </div>
            </div>
          )}
        </div>
      ))}

      {/* Video Navigation */}
      <div className="video-navigation">
        <div className="video-dots">
          {videos.map((_, index) => (
            <button
              key={index}
              className={`video-dot ${index === currentVideoIndex ? 'active' : ''}`}
              onClick={() => scrollToVideo(index)}
            />
          ))}
        </div>
      </div>

      {/* Category Filter (if on category page) */}
      {category && (
        <div className="category-header">
          <h2>{category.charAt(0).toUpperCase() + category.slice(1)} Products</h2>
          <button onClick={() => navigate('/videos')} className="btn btn-secondary">
            All Categories
          </button>
        </div>
      )}
    </div>
  );
};

export default VideoFeedPage;
