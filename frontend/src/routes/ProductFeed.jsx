import { useEffect, useState } from 'react';
import { fetchProducts, fetchVideos } from '../services/api.js';
import VideoCard from '../components/VideoCard.jsx';

export default function ProductFeed({ user }) {
  const [products, setProducts] = useState([]);
  const [videos, setVideos] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    async function load() {
      try {
        const [productData, videoData] = await Promise.all([fetchProducts(), fetchVideos()]);
        setProducts(productData);
        setVideos(videoData);
      } catch (err) {
        setError('Unable to load marketplace data.');
      }
    }
    load();
  }, []);

  return (
    <section className="space-y-8">
      <div className="rounded-3xl border border-slate-800 bg-slate-900/95 p-6 shadow-xl shadow-slate-950/20">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <h1 className="text-3xl font-semibold text-white">Shop with product videos and chat negotiation</h1>
            <p className="mt-2 text-slate-400">Scroll through seller videos, discover deals, and negotiate prices in a modern marketplace experience.</p>
          </div>
          <div className="rounded-3xl bg-slate-950 p-4 text-sm text-slate-300">
            {user ? `Logged in as ${user.fullName} (${user.role})` : 'Login to unlock chat and seller tools.'}
          </div>
        </div>
      </div>

      {error ? <div className="rounded-3xl bg-rose-500/10 px-5 py-4 text-sm text-rose-200">{error}</div> : null}

      <div className="overflow-hidden rounded-[2rem] border border-slate-800 bg-slate-950/95">
        <div className="h-[620px] overflow-y-scroll scroll-snap-y">
          {videos.length > 0 ? (
            videos.map((video) => <VideoCard key={video.id} product={video} />)
          ) : (
            <div className="flex min-h-[520px] items-center justify-center p-8 text-center text-slate-400">No videos available yet. Sellers can upload product videos to showcase offers.</div>
          )}
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {products.length > 0 ? (
          products.map((product) => (
            <article key={product.id} className="rounded-3xl border border-slate-800 bg-slate-900 p-6 transition hover:-translate-y-0.5 hover:border-brand/60">
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div>
                  <h2 className="text-2xl font-semibold text-white">{product.title}</h2>
                  <p className="mt-2 text-slate-400">{product.description}</p>
                </div>
                <span className="rounded-full bg-brand/10 px-4 py-2 text-sm font-semibold text-brand">RWF {product.price.toFixed(2)}</span>
              </div>
              <div className="mt-4 flex flex-wrap items-center gap-3 text-sm text-slate-400">
                <span>Seller: {product.seller.fullName}</span>
                <span>Category: {product.category || 'General'}</span>
                <span>{new Date(product.createdAt).toLocaleDateString()}</span>
              </div>
            </article>
          ))
        ) : (
          <div className="rounded-3xl border border-slate-800 bg-slate-900 p-8 text-center text-slate-400">No items found. Sellers can list products and attach short demo videos.</div>
        )}
      </div>
    </section>
  );
}
