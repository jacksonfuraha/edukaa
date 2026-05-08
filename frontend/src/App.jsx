import { useEffect, useState } from 'react';
import { Routes, Route, NavLink, useNavigate } from 'react-router-dom';
import Home from './routes/Home.jsx';
import Auth from './routes/Auth.jsx';
import ProductFeed from './routes/ProductFeed.jsx';
import Chat from './routes/Chat.jsx';
import { fetchProfile } from './services/api.js';

function App() {
  const [user, setUser] = useState(null);
  const [loadingProfile, setLoadingProfile] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const saved = localStorage.getItem('iduka_user');
    if (saved) {
      setUser(JSON.parse(saved));
    }
    async function loadProfile() {
      const token = localStorage.getItem('iduka_token');
      if (!token) {
        setLoadingProfile(false);
        return;
      }
      try {
        const profile = await fetchProfile();
        setUser(profile);
        localStorage.setItem('iduka_user', JSON.stringify(profile));
      } catch (error) {
        console.warn('Profile load failed', error);
        localStorage.removeItem('iduka_token');
        localStorage.removeItem('iduka_user');
      } finally {
        setLoadingProfile(false);
      }
    }
    loadProfile();
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('iduka_token');
    localStorage.removeItem('iduka_user');
    setUser(null);
    navigate('/');
  };

  const handleLogin = (newUser, token) => {
    localStorage.setItem('iduka_user', JSON.stringify(newUser));
    localStorage.setItem('iduka_token', token);
    setUser(newUser);
    navigate('/feed');
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100">
      <header className="sticky top-0 z-20 border-b border-slate-800 bg-slate-950/95 backdrop-blur-md">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-4 sm:px-6">
          <div>
            <NavLink to="/" className="text-xl font-semibold text-brand">IDUKA Marketplace</NavLink>
            <p className="text-sm text-slate-400">Empowering Rwandan buyers and sellers with digital commerce.</p>
          </div>
          <nav className="flex items-center gap-3">
            <NavLink to="/" className="rounded-lg px-3 py-2 text-sm text-slate-300 hover:bg-slate-800">Home</NavLink>
            <NavLink to="/feed" className="rounded-lg px-3 py-2 text-sm text-slate-300 hover:bg-slate-800">Feed</NavLink>
            <NavLink to="/chat" className="rounded-lg px-3 py-2 text-sm text-slate-300 hover:bg-slate-800">Chat</NavLink>
            {user ? (
              <button onClick={handleLogout} className="rounded-lg bg-brand px-3 py-2 text-sm font-semibold text-slate-950">Logout</button>
            ) : (
              <NavLink to="/auth?mode=login" className="rounded-lg bg-brand px-3 py-2 text-sm font-semibold text-slate-950">Login</NavLink>
            )}
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-4 py-8 sm:px-6">
        <Routes>
          <Route path="/" element={<Home user={user} />} />
          <Route path="/auth" element={<Auth onLogin={handleLogin} />} />
          <Route path="/feed" element={<ProductFeed user={user} />} />
          <Route path="/chat" element={<Chat user={user} />} />
        </Routes>
      </main>

      <footer className="border-t border-slate-800 bg-slate-950/90 py-6 text-center text-sm text-slate-500">
        Built with React + Tailwind CSS. Recommended database: PostgreSQL for scalable hosting.
      </footer>
    </div>
  );
}

export default App;
