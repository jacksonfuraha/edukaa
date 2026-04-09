import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import { FiUser, FiMail, FiPhone, FiMapPin, FiEdit2, FiCamera, FiSave, FiX } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';
import toast from 'react-toastify';

const ProfilePage = () => {
  const { user, updateUser } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [editMode, setEditMode] = useState('profile'); // 'profile' or 'address'
  const queryClient = useQueryClient();

  // Profile state
  const [profileData, setProfileData] = useState({
    username: user?.username || '',
    full_name: user?.full_name || '',
    phone: user?.phone || '',
    email: user?.email || ''
  });

  // Address state
  const [addressData, setAddressData] = useState({
    country: 'Rwanda',
    province: '',
    district: '',
    sector: '',
    cell: '',
    village: '',
    street_address: ''
  });

  // Fetch user profile
  const { data: profileResponse, isLoading } = useQuery(
    'userProfile',
    async () => {
      const response = await axios.get('/api/users/profile');
      return response.data.data;
    },
    {
      onSuccess: (data) => {
        setProfileData({
          username: data.user.username,
          full_name: data.user.full_name,
          phone: data.user.phone,
          email: data.user.email
        });
        
        if (data.user.country) {
          setAddressData({
            country: data.user.country || 'Rwanda',
            province: data.user.province || '',
            district: data.user.district || '',
            sector: data.user.sector || '',
            cell: data.user.cell || '',
            village: data.user.village || '',
            street_address: data.user.street_address || ''
          });
        }
      }
    }
  );

  // Update profile mutation
  const updateProfileMutation = useMutation(
    async (profileUpdateData) => {
      const response = await axios.put('/api/users/profile', profileUpdateData);
      return response.data.data;
    },
    {
      onSuccess: (data) => {
        updateUser(data.user);
        toast.success('Profile updated successfully!');
        setIsEditing(false);
        queryClient.invalidateQueries('userProfile');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to update profile');
      }
    }
  );

  // Add address mutation
  const addAddressMutation = useMutation(
    async (address) => {
      const response = await axios.post('/api/users/addresses', address);
      return response.data.data;
    },
    {
      onSuccess: () => {
        toast.success('Address added successfully!');
        setEditMode('profile');
        queryClient.invalidateQueries('userProfile');
        queryClient.invalidateQueries('userAddresses');
      },
      onError: (error) => {
        toast.error(error.response?.data?.message || 'Failed to add address');
      }
    }
  );

  const handleProfileChange = (e) => {
    setProfileData({
      ...profileData,
      [e.target.name]: e.target.value
    });
  };

  const handleAddressChange = (e) => {
    setAddressData({
      ...addressData,
      [e.target.name]: e.target.value
    });
  };

  const handleProfileSubmit = (e) => {
    e.preventDefault();
    updateProfileMutation.mutate(profileData);
  };

  const handleAddressSubmit = (e) => {
    e.preventDefault();
    addAddressMutation.mutate(addressData);
  };

  const cancelEdit = () => {
    setIsEditing(false);
    setEditMode('profile');
    // Reset form data
    if (profileResponse?.user) {
      setProfileData({
        username: profileResponse.user.username,
        full_name: profileResponse.user.full_name,
        phone: profileResponse.user.phone,
        email: profileResponse.user.email
      });
    }
  };

  if (isLoading) {
    return (
      <div className="profile-loading">
        <div className="spinner"></div>
        <p>Loading profile...</p>
      </div>
    );
  }

  const userProfile = profileResponse?.user;

  return (
    <div className="profile-page">
      <div className="container">
        <div className="profile-header">
          <h1>My Profile</h1>
          <p>Manage your personal information and address</p>
        </div>

        <div className="profile-content">
          {/* Profile Card */}
          <div className="profile-card">
            <div className="profile-avatar-section">
              <div className="avatar-container">
                <div className="avatar">
                  {userProfile?.full_name?.[0]?.toUpperCase() || userProfile?.username?.[0]?.toUpperCase()}
                </div>
                <button className="avatar-edit-btn">
                  <FiCamera />
                </button>
              </div>
              <div className="avatar-info">
                <h2>{userProfile?.full_name || userProfile?.username}</h2>
                <p className="user-type">{userProfile?.user_type}</p>
                <p className="member-since">Member since {new Date(userProfile?.created_at).toLocaleDateString()}</p>
              </div>
            </div>

            <div className="profile-actions">
              {!isEditing ? (
                <button 
                  className="btn btn-primary"
                  onClick={() => setIsEditing(true)}
                >
                  <FiEdit2 /> Edit Profile
                </button>
              ) : (
                <div className="edit-actions">
                  <button 
                    className="btn btn-success"
                    onClick={() => setEditMode('address')}
                  >
                    <FiMapPin /> Add Address
                  </button>
                  <button 
                    className="btn btn-secondary"
                    onClick={cancelEdit}
                  >
                    <FiX /> Cancel
                  </button>
                </div>
              )}
            </div>
          </div>

          {/* Edit Forms */}
          {isEditing && (
            <div className="edit-forms">
              {editMode === 'profile' ? (
                <div className="form-card">
                  <h3>Edit Profile Information</h3>
                  <form onSubmit={handleProfileSubmit}>
                    <div className="form-row">
                      <div className="form-group">
                        <label htmlFor="username">Username</label>
                        <input
                          type="text"
                          id="username"
                          name="username"
                          value={profileData.username}
                          onChange={handleProfileChange}
                          className="form-control"
                          required
                        />
                      </div>
                      <div className="form-group">
                        <label htmlFor="full_name">Full Name</label>
                        <input
                          type="text"
                          id="full_name"
                          name="full_name"
                          value={profileData.full_name}
                          onChange={handleProfileChange}
                          className="form-control"
                          required
                        />
                      </div>
                    </div>

                    <div className="form-row">
                      <div className="form-group">
                        <label htmlFor="email">Email</label>
                        <input
                          type="email"
                          id="email"
                          name="email"
                          value={profileData.email}
                          onChange={handleProfileChange}
                          className="form-control"
                          disabled
                        />
                        <small>Email cannot be changed</small>
                      </div>
                      <div className="form-group">
                        <label htmlFor="phone">Phone Number</label>
                        <input
                          type="tel"
                          id="phone"
                          name="phone"
                          value={profileData.phone}
                          onChange={handleProfileChange}
                          className="form-control"
                          required
                        />
                      </div>
                    </div>

                    <div className="form-actions">
                      <button 
                        type="submit" 
                        className="btn btn-primary"
                        disabled={updateProfileMutation.isLoading}
                      >
                        <FiSave /> {updateProfileMutation.isLoading ? 'Saving...' : 'Save Changes'}
                      </button>
                    </div>
                  </form>
                </div>
              ) : (
                <div className="form-card">
                  <h3>Add Address Information</h3>
                  <form onSubmit={handleAddressSubmit}>
                    <div className="form-group">
                      <label htmlFor="country">Country</label>
                      <input
                        type="text"
                        id="country"
                        name="country"
                        value={addressData.country}
                        onChange={handleAddressChange}
                        className="form-control"
                        disabled
                      />
                    </div>

                    <div className="form-row">
                      <div className="form-group">
                        <label htmlFor="province">Province</label>
                        <select
                          id="province"
                          name="province"
                          value={addressData.province}
                          onChange={handleAddressChange}
                          className="form-control"
                          required
                        >
                          <option value="">Select Province</option>
                          <option value="Kigali">Kigali</option>
                          <option value="Northern">Northern</option>
                          <option value="Southern">Southern</option>
                          <option value="Eastern">Eastern</option>
                          <option value="Western">Western</option>
                        </select>
                      </div>
                      <div className="form-group">
                        <label htmlFor="district">District</label>
                        <input
                          type="text"
                          id="district"
                          name="district"
                          value={addressData.district}
                          onChange={handleAddressChange}
                          className="form-control"
                          required
                        />
                      </div>
                    </div>

                    <div className="form-row">
                      <div className="form-group">
                        <label htmlFor="sector">Sector</label>
                        <input
                          type="text"
                          id="sector"
                          name="sector"
                          value={addressData.sector}
                          onChange={handleAddressChange}
                          className="form-control"
                          required
                        />
                      </div>
                      <div className="form-group">
                        <label htmlFor="cell">Cell</label>
                        <input
                          type="text"
                          id="cell"
                          name="cell"
                          value={addressData.cell}
                          onChange={handleAddressChange}
                          className="form-control"
                          required
                        />
                      </div>
                    </div>

                    <div className="form-row">
                      <div className="form-group">
                        <label htmlFor="village">Village</label>
                        <input
                          type="text"
                          id="village"
                          name="village"
                          value={addressData.village}
                          onChange={handleAddressChange}
                          className="form-control"
                          required
                        />
                      </div>
                      <div className="form-group">
                        <label htmlFor="street_address">Street Address (Optional)</label>
                        <input
                          type="text"
                          id="street_address"
                          name="street_address"
                          value={addressData.street_address}
                          onChange={handleAddressChange}
                          className="form-control"
                          placeholder="Street name or landmark"
                        />
                      </div>
                    </div>

                    <div className="form-actions">
                      <button 
                        type="submit" 
                        className="btn btn-primary"
                        disabled={addAddressMutation.isLoading}
                      >
                        <FiSave /> {addAddressMutation.isLoading ? 'Adding...' : 'Add Address'}
                      </button>
                    </div>
                  </form>
                </div>
              )}
            </div>
          )}

          {/* Current Address Display */}
          {userProfile?.province && (
            <div className="address-card">
              <h3>Current Address</h3>
              <div className="address-display">
                <div className="address-item">
                  <FiMapPin className="address-icon" />
                  <div className="address-text">
                    <p>
                      {userProfile.street_address && `${userProfile.street_address}, `}
                      {userProfile.village}, {userProfile.cell}, {userProfile.sector}
                    </p>
                    <p>{userProfile.district}, {userProfile.province}</p>
                    <p>{userProfile.country}</p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Account Statistics */}
          <div className="stats-card">
            <h3>Account Statistics</h3>
            <div className="stats-grid">
              <div className="stat-item">
                <div className="stat-number">
                  {userProfile?.user_type === 'seller' ? '0' : '0'}
                </div>
                <div className="stat-label">
                  {userProfile?.user_type === 'seller' ? 'Products Listed' : 'Orders Placed'}
                </div>
              </div>
              <div className="stat-item">
                <div className="stat-number">0</div>
                <div className="stat-label">Reviews</div>
              </div>
              <div className="stat-item">
                <div className="stat-number">0</div>
                <div className="stat-label">Messages</div>
              </div>
              <div className="stat-item">
                <div className="stat-number">
                  {userProfile?.is_verified ? 'Verified' : 'Pending'}
                </div>
                <div className="stat-label">Account Status</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;
