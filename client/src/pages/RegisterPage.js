import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { FiUser, FiMail, FiLock, FiPhone, FiEye, FiEyeOff, FiMapPin, FiHome } from 'react-icons/fi';

const RegisterPage = () => {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    full_name: '',
    phone: '',
    user_type: 'buyer',
    address: {
      country: 'Rwanda',
      province: '',
      district: '',
      sector: '',
      cell: '',
      village: '',
      street_address: ''
    }
  });
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const { register } = useAuth();
  const navigate = useNavigate();

  const rwandaProvinces = [
    'Kigali', 'Northern', 'Southern', 'Eastern', 'Western'
  ];

  const handleChange = (e) => {
    const { name, value } = e.target;
    
    if (name.startsWith('address.')) {
      const addressField = name.split('.')[1];
      setFormData({
        ...formData,
        address: {
          ...formData.address,
          [addressField]: value
        }
      });
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.username.trim()) newErrors.username = 'Username is required';
    if (formData.username.length < 3) newErrors.username = 'Username must be at least 3 characters';

    if (!formData.email.trim()) newErrors.email = 'Email is required';
    if (!/^\S+@\S+\.\S+$/.test(formData.email)) newErrors.email = 'Email is invalid';

    if (!formData.password) newErrors.password = 'Password is required';
    if (formData.password.length < 6) newErrors.password = 'Password must be at least 6 characters';

    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match';
    }

    if (!formData.full_name.trim()) newErrors.full_name = 'Full name is required';

    if (!formData.phone.trim()) newErrors.phone = 'Phone number is required';
    if (formData.phone.length < 10) newErrors.phone = 'Phone number must be at least 10 digits';

    // Address validation
    if (!formData.address.province) newErrors.province = 'Province is required';
    if (!formData.address.district) newErrors.district = 'District is required';
    if (!formData.address.sector) newErrors.sector = 'Sector is required';
    if (!formData.address.cell) newErrors.cell = 'Cell is required';
    if (!formData.address.village) newErrors.village = 'Village is required';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;

    setLoading(true);

    try {
      const { confirmPassword, ...registrationData } = formData;
      const result = await register(registrationData);
      if (result.success) {
        navigate('/dashboard');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="container">
        <div className="auth-container">
          <div className="auth-card register-card">
            <div className="auth-header">
              <h1>Create Account</h1>
              <p>Join IDUKA - Rwanda's Online Marketplace</p>
            </div>

            <form onSubmit={handleSubmit} className="auth-form">
              {/* User Type Selection */}
              <div className="form-group">
                <label>Account Type</label>
                <div className="user-type-selector">
                  <label className="user-type-option">
                    <input
                      type="radio"
                      name="user_type"
                      value="buyer"
                      checked={formData.user_type === 'buyer'}
                      onChange={handleChange}
                    />
                    <span className="radio-label">Buyer</span>
                  </label>
                  <label className="user-type-option">
                    <input
                      type="radio"
                      name="user_type"
                      value="seller"
                      checked={formData.user_type === 'seller'}
                      onChange={handleChange}
                    />
                    <span className="radio-label">Seller</span>
                  </label>
                </div>
              </div>

              {/* Basic Information */}
              <div className="form-row">
                <div className="form-group">
                  <label htmlFor="username">Username</label>
                  <div className="input-with-icon">
                    <FiUser className="input-icon" />
                    <input
                      type="text"
                      id="username"
                      name="username"
                      value={formData.username}
                      onChange={handleChange}
                      className={`form-control ${errors.username ? 'error' : ''}`}
                      placeholder="Choose a username"
                      required
                    />
                  </div>
                  {errors.username && <span className="error-message">{errors.username}</span>}
                </div>

                <div className="form-group">
                  <label htmlFor="full_name">Full Name</label>
                  <div className="input-with-icon">
                    <FiUser className="input-icon" />
                    <input
                      type="text"
                      id="full_name"
                      name="full_name"
                      value={formData.full_name}
                      onChange={handleChange}
                      className={`form-control ${errors.full_name ? 'error' : ''}`}
                      placeholder="Enter your full name"
                      required
                    />
                  </div>
                  {errors.full_name && <span className="error-message">{errors.full_name}</span>}
                </div>
              </div>

              <div className="form-group">
                <label htmlFor="email">Email Address</label>
                <div className="input-with-icon">
                  <FiMail className="input-icon" />
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    className={`form-control ${errors.email ? 'error' : ''}`}
                    placeholder="Enter your email"
                    required
                  />
                </div>
                {errors.email && <span className="error-message">{errors.email}</span>}
              </div>

              <div className="form-group">
                <label htmlFor="phone">Phone Number</label>
                <div className="input-with-icon">
                  <FiPhone className="input-icon" />
                  <input
                    type="tel"
                    id="phone"
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    className={`form-control ${errors.phone ? 'error' : ''}`}
                    placeholder="Enter your phone number"
                    required
                  />
                </div>
                {errors.phone && <span className="error-message">{errors.phone}</span>}
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label htmlFor="password">Password</label>
                  <div className="input-with-icon">
                    <FiLock className="input-icon" />
                    <input
                      type={showPassword ? 'text' : 'password'}
                      id="password"
                      name="password"
                      value={formData.password}
                      onChange={handleChange}
                      className={`form-control ${errors.password ? 'error' : ''}`}
                      placeholder="Create a password"
                      required
                    />
                    <button
                      type="button"
                      className="password-toggle"
                      onClick={() => setShowPassword(!showPassword)}
                    >
                      {showPassword ? <FiEyeOff /> : <FiEye />}
                    </button>
                  </div>
                  {errors.password && <span className="error-message">{errors.password}</span>}
                </div>

                <div className="form-group">
                  <label htmlFor="confirmPassword">Confirm Password</label>
                  <div className="input-with-icon">
                    <FiLock className="input-icon" />
                    <input
                      type={showConfirmPassword ? 'text' : 'password'}
                      id="confirmPassword"
                      name="confirmPassword"
                      value={formData.confirmPassword}
                      onChange={handleChange}
                      className={`form-control ${errors.confirmPassword ? 'error' : ''}`}
                      placeholder="Confirm your password"
                      required
                    />
                    <button
                      type="button"
                      className="password-toggle"
                      onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    >
                      {showConfirmPassword ? <FiEyeOff /> : <FiEye />}
                    </button>
                  </div>
                  {errors.confirmPassword && <span className="error-message">{errors.confirmPassword}</span>}
                </div>
              </div>

              {/* Address Information */}
              <div className="address-section">
                <h3><FiMapPin /> Address Information</h3>
                
                <div className="form-group">
                  <label htmlFor="address.province">Province</label>
                  <select
                    id="address.province"
                    name="address.province"
                    value={formData.address.province}
                    onChange={handleChange}
                    className={`form-control ${errors.province ? 'error' : ''}`}
                    required
                  >
                    <option value="">Select Province</option>
                    {rwandaProvinces.map(province => (
                      <option key={province} value={province}>{province}</option>
                    ))}
                  </select>
                  {errors.province && <span className="error-message">{errors.province}</span>}
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="address.district">District</label>
                    <input
                      type="text"
                      id="address.district"
                      name="address.district"
                      value={formData.address.district}
                      onChange={handleChange}
                      className={`form-control ${errors.district ? 'error' : ''}`}
                      placeholder="Enter district"
                      required
                    />
                    {errors.district && <span className="error-message">{errors.district}</span>}
                  </div>

                  <div className="form-group">
                    <label htmlFor="address.sector">Sector</label>
                    <input
                      type="text"
                      id="address.sector"
                      name="address.sector"
                      value={formData.address.sector}
                      onChange={handleChange}
                      className={`form-control ${errors.sector ? 'error' : ''}`}
                      placeholder="Enter sector"
                      required
                    />
                    {errors.sector && <span className="error-message">{errors.sector}</span>}
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="address.cell">Cell</label>
                    <input
                      type="text"
                      id="address.cell"
                      name="address.cell"
                      value={formData.address.cell}
                      onChange={handleChange}
                      className={`form-control ${errors.cell ? 'error' : ''}`}
                      placeholder="Enter cell"
                      required
                    />
                    {errors.cell && <span className="error-message">{errors.cell}</span>}
                  </div>

                  <div className="form-group">
                    <label htmlFor="address.village">Village</label>
                    <input
                      type="text"
                      id="address.village"
                      name="address.village"
                      value={formData.address.village}
                      onChange={handleChange}
                      className={`form-control ${errors.village ? 'error' : ''}`}
                      placeholder="Enter village"
                      required
                    />
                    {errors.village && <span className="error-message">{errors.village}</span>}
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="address.street_address">Street Address (Optional)</label>
                  <div className="input-with-icon">
                    <FiHome className="input-icon" />
                    <input
                      type="text"
                      id="address.street_address"
                      name="address.street_address"
                      value={formData.address.street_address}
                      onChange={handleChange}
                      className="form-control"
                      placeholder="Enter street address or landmark"
                    />
                  </div>
                </div>
              </div>

              <button
                type="submit"
                className="btn btn-primary btn-full"
                disabled={loading}
              >
                {loading ? 'Creating Account...' : 'Create Account'}
              </button>
            </form>

            <div className="auth-footer">
              <p>
                Already have an account? <Link to="/login">Sign in</Link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RegisterPage;
