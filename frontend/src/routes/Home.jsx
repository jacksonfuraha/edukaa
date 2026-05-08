import { Link } from 'react-router-dom';

export default function Home({ user }) {
  return (
    <section className="space-y-8 pb-12">
      <div className="rounded-3xl border border-slate-800 bg-slate-900/95 p-8 shadow-xl shadow-slate-950/40 sm:p-12">
        <div className="grid gap-8 lg:grid-cols-[1.2fr_0.8fr] lg:items-center">
          <div className="space-y-6">
            <span className="rounded-full bg-brand/10 px-4 py-2 text-sm font-semibold text-brand">IDUKA Rwanda</span>
            <h1 className="text-4xl font-bold tracking-tight text-white sm:text-5xl">Digital marketplace for youth entrepreneurs and customers across Rwanda.</h1>
            <p className="max-w-2xl text-lg leading-8 text-slate-300">Create a virtual shop, upload product videos, negotiate through chat, and deliver value nationwide using mobile money-friendly commerce.</p>
            <div className="flex flex-wrap gap-3">
              <Link to="/auth?mode=signup" className="rounded-full bg-brand px-6 py-3 text-sm font-semibold text-slate-950 transition hover:bg-teal-400">Create your account</Link>
              <Link to="/auth?mode=login" className="rounded-full border border-slate-700 px-6 py-3 text-sm text-slate-200 transition hover:border-brand">Login</Link>
            </div>
          </div>
          <div className="space-y-4 rounded-3xl bg-slate-950 p-6 shadow-inner shadow-slate-950/30">
            <p className="text-sm uppercase tracking-[0.2em] text-slate-500">Fast access for</p>
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="rounded-3xl border border-slate-800 bg-slate-900 p-5">
                <h2 className="text-lg font-semibold text-white">Buyer</h2>
                <p className="mt-2 text-sm text-slate-400">Browse products, watch promotional videos, and chat directly with sellers to bargain before buying.</p>
              </div>
              <div className="rounded-3xl border border-slate-800 bg-slate-900 p-5">
                <h2 className="text-lg font-semibold text-white">Seller</h2>
                <p className="mt-2 text-sm text-slate-400">Open a low-cost virtual shop, upload product videos, verify identity, and grow your customer reach digitally.</p>
              </div>
            </div>
            <div className="rounded-3xl border border-slate-800 bg-slate-900 p-5">
              <h2 className="text-lg font-semibold text-white">Why IDUKA?</h2>
              <ul className="mt-3 space-y-2 text-sm text-slate-400">
                <li>• Reduce startup cost by eliminating physical rent.</li>
                <li>• Promote youth entrepreneurship and digital skills.</li>
                <li>• Offer a mobile-first, responsive marketplace experience.</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <article className="rounded-3xl border border-slate-800 bg-slate-900 p-6">
          <h3 className="text-xl font-semibold text-white">Video-first discovery</h3>
          <p className="mt-3 text-slate-400">Showcase items the way customers love to consume them — short product videos that feel like TikTok stories.</p>
        </article>
        <article className="rounded-3xl border border-slate-800 bg-slate-900 p-6">
          <h3 className="text-xl font-semibold text-white">Secure seller verification</h3>
          <p className="mt-3 text-slate-400">Sellers submit ID and TIN data so buyers can trust verified merchants and reduce fraud.</p>
        </article>
        <article className="rounded-3xl border border-slate-800 bg-slate-900 p-6">
          <h3 className="text-xl font-semibold text-white">Full delivery address capture</h3>
          <p className="mt-3 text-slate-400">Users include country, province, district, sector, cell, and village during registration for accurate shipping.</p>
        </article>
      </div>

      {user ? (
        <div className="rounded-3xl border border-slate-800 bg-slate-900 p-6">
          <h2 className="text-2xl font-semibold">Welcome back, {user.fullName}</h2>
          <p className="mt-2 text-slate-400">Your role is {user.role.toLowerCase()}. Use the feed to browse products and the chat page to negotiate prices.</p>
        </div>
      ) : null}
    </section>
  );
}
