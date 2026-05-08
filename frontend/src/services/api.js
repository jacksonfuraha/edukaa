import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

const api = axios.create({
  baseURL: `${API_BASE}/api`,
  headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('iduka_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export async function signup(payload) {
  const response = await api.post('/auth/signup', payload);
  return response.data;
}

export async function login(payload) {
  const response = await api.post('/auth/login', payload);
  return response.data;
}

export async function fetchProducts() {
  const response = await api.get('/products');
  return response.data.products;
}

export async function fetchVideos() {
  const response = await api.get('/videos');
  return response.data.videos;
}

export async function fetchProfile() {
  const response = await api.get('/profile');
  return response.data.user;
}

export async function sendMessage(payload) {
  const response = await api.post('/chat', payload);
  return response.data.message;
}

export async function fetchChat(userId) {
  const response = await api.get(`/chat/${userId}`);
  return response.data.messages;
}
