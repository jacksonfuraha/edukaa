import { useMemo, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { signup, login } from '../services/api.js';
import AddressFields from '../components/AddressFields.jsx';

const initialForm = {
  email: '',
  password: '',
  fullName: '',
  phone: '',
  role: 'BUYER',
  country: '',
  province: '',
  district: '',
  sector: '',
  cell: '',
  village: '',
  idCardNumber: '',
  tinNumber: ''
};

export default function Auth({ onLogin }) {
  const [params] = useSearchParams();
  const mode = params.get('mode') === 'signup' ? 'signup' : 'login';
  const [form, setForm] = useState(initialForm);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const navigate = useNavigate();

  const isSeller = form.role === 'SELLER';
  const title = mode === 'signup' ? 'Create an account' : 'Login to IDUKA';

  const submitText = mode === 'signup' ? 'Register now' : 'Login';

  const handleChange = (event) => {
    const { name, value } = event.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');
    setMessage('');
    setSubmitting(true);
    try {
      if (mode === 'signup') {
        const response = await signup(form);
        onLogin(response.user, response.token);
        setMessage('Registration successful. Redirecting to the feed...');
      } else {
        const response = await login({ email: form.email, password: form.password });
        onLogin(response.user, response.token);
      }
    } catch (err) {
      setError(err.response?.data?.error || 'Request failed.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <section className="mx-auto max-w-3xl rounded-[2rem] border border-slate-800 bg-slate-900/95 p-8 shadow-xl shadow-slate-950/40">
      <div className="mb-6 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-white">{title}</h1>
          <p className="text-sm text-slate-400">Sign in or sign up with a buyer or seller profile.</p>
        </div>
        <div className="flex flex-wrap gap-3">
          <button onClick={() => navigate('/auth?mode=login')} className={`rounded-full px-4 py-2 text-sm ${mode === 'login' ? 'bg-brand text-slate-950' : 'border border-slate-700 text-slate-300'}`}>
            Login
          </button>
          <button onClick={() => navigate('/auth?mode=signup')} className={`rounded-full px-4 py-2 text-sm ${mode === 'signup' ? 'bg-brand text-slate-950' : 'border border-slate-700 text-slate-300'}`}>
            Sign up
          </button>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {mode === 'signup' ? (
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="space-y-2 text-sm text-slate-300">
              Full name
              <input required name="fullName" value={form.fullName} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
            </label>
            <label className="space-y-2 text-sm text-slate-300">
              Phone
              <input required name="phone" value={form.phone} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
            </label>
            <label className="space-y-2 text-sm text-slate-300">
              Email
              <input required type="email" name="email" value={form.email} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
            </label>
            <label className="space-y-2 text-sm text-slate-300">
              Password
              <input required type="password" name="password" value={form.password} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
            </label>
          </div>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="space-y-2 text-sm text-slate-300">
              Email
              <input required type="email" name="email" value={form.email} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
            </label>
            <label className="space-y-2 text-sm text-slate-300">
              Password
              <input required type="password" name="password" value={form.password} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
            </label>
          </div>
        )}

        {mode === 'signup' ? (
          <div className="grid gap-4">
            <label className="space-y-2 text-sm text-slate-300">
              Role
              <select name="role" value={form.role} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100">
                <option value="BUYER">Buyer</option>
                <option value="SELLER">Seller</option>
              </select>
            </label>
            <AddressFields form={form} onChange={handleChange} />
            {isSeller ? (
              <div className="grid gap-4 sm:grid-cols-2">
                <label className="space-y-2 text-sm text-slate-300">
                  ID card number
                  <input required name="idCardNumber" value={form.idCardNumber} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
                </label>
                <label className="space-y-2 text-sm text-slate-300">
                  TIN number
                  <input required name="tinNumber" value={form.tinNumber} onChange={handleChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
                </label>
              </div>
            ) : null}
          </div>
        ) : null}

        <div className="space-y-4">
          {error ? <p className="rounded-3xl bg-rose-500/10 px-4 py-3 text-sm text-rose-300">{error}</p> : null}
          {message ? <p className="rounded-3xl bg-emerald-500/10 px-4 py-3 text-sm text-emerald-300">{message}</p> : null}
          <button type="submit" disabled={submitting} className="w-full rounded-3xl bg-brand px-6 py-4 text-base font-semibold text-slate-950 transition hover:bg-teal-400 disabled:opacity-70">
            {submitting ? 'Processing...' : submitText}
          </button>
        </div>
      </form>
    </section>
  );
}
