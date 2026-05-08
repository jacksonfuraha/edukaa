import { useEffect, useState } from 'react';
import { fetchChat, sendMessage } from '../services/api.js';

export default function Chat({ user }) {
  const [receiverId, setReceiverId] = useState('');
  const [messages, setMessages] = useState([]);
  const [content, setContent] = useState('');
  const [error, setError] = useState('');
  const [status, setStatus] = useState('');

  useEffect(() => {
    if (receiverId) {
      loadMessages(receiverId);
    }
  }, [receiverId]);

  const loadMessages = async (id) => {
    try {
      const data = await fetchChat(id);
      setMessages(data);
      setError('');
    } catch (err) {
      setError('Could not load chat. Use a verified seller or buyer user ID.');
      setMessages([]);
    }
  };

  const handleSend = async (event) => {
    event.preventDefault();
    if (!receiverId || !content.trim()) return;
    try {
      const message = await sendMessage({ receiverId, content });
      setMessages((prev) => [...prev, message]);
      setContent('');
      setStatus('Message sent.');
    } catch (err) {
      setError('Failed to send the message.');
    }
  };

  if (!user) {
    return (
      <div className="rounded-3xl border border-slate-800 bg-slate-900/95 p-8 text-center text-slate-300">
        <h2 className="text-2xl font-semibold text-white">Chat is only available after login.</h2>
        <p className="mt-3">Login as a buyer or seller to negotiate product prices and confirm offers directly.</p>
      </div>
    );
  }

  return (
    <section className="space-y-8">
      <div className="rounded-3xl border border-slate-800 bg-slate-900/95 p-6 shadow-xl shadow-slate-950/20">
        <h1 className="text-3xl font-semibold text-white">Buyer-Seller Negotiation</h1>
        <p className="mt-2 text-slate-400">Use a verified user ID to open a chat session, then bargain and confirm product details in one place.</p>
      </div>

      <div className="grid gap-6 lg:grid-cols-[280px_1fr]">
        <section className="rounded-3xl border border-slate-800 bg-slate-900/95 p-6">
          <h2 className="text-xl font-semibold text-white">Chat controls</h2>
          <div className="mt-4 space-y-4">
            <label className="block text-sm text-slate-300">
              Buyer/Seller user ID
              <input value={receiverId} onChange={(e) => setReceiverId(e.target.value)} className="mt-2 w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" placeholder="Enter receiver id" />
            </label>
            <button onClick={() => loadMessages(receiverId)} className="w-full rounded-3xl bg-brand px-4 py-3 text-sm font-semibold text-slate-950">Load conversation</button>
          </div>
          <div className="mt-6 rounded-3xl bg-slate-950/80 p-4 text-sm text-slate-400">
            <p>Use the other user ID to start a chat. For demo, create the seller and buyer accounts first, then use the numeric user id from the backend response.</p>
          </div>
        </section>

        <section className="rounded-3xl border border-slate-800 bg-slate-900/95 p-6">
          <div className="flex items-center justify-between gap-4">
            <h2 className="text-xl font-semibold text-white">Messages</h2>
            <span className="rounded-full bg-slate-800 px-3 py-1 text-sm text-slate-400">Chat with {receiverId || '...'}</span>
          </div>
          <div className="mt-4 max-h-[520px] space-y-4 overflow-y-auto rounded-3xl bg-slate-950/80 p-4">
            {messages.length > 0 ? (
              messages.map((message) => (
                <div key={message.id} className={`rounded-3xl p-4 ${message.senderId === user.id ? 'bg-brand/10 text-slate-100 ml-auto max-w-[85%]' : 'bg-slate-800 text-slate-200'}`}>
                  <p>{message.content}</p>
                  <p className="mt-2 text-xs text-slate-500">{new Date(message.createdAt).toLocaleString()}</p>
                </div>
              ))
            ) : (
              <p className="text-slate-500">No messages yet. Load the conversation and send your first offer.</p>
            )}
          </div>
          <form onSubmit={handleSend} className="mt-6 space-y-4">
            <textarea value={content} onChange={(e) => setContent(e.target.value)} rows="4" className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" placeholder="Write your negotiation message" />
            {error ? <p className="text-sm text-rose-300">{error}</p> : null}
            {status ? <p className="text-sm text-emerald-300">{status}</p> : null}
            <button type="submit" className="w-full rounded-3xl bg-brand px-5 py-3 text-sm font-semibold text-slate-950">Send message</button>
          </form>
        </section>
      </div>
    </section>
  );
}
