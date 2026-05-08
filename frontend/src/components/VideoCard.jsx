export default function VideoCard({ product }) {
  return (
    <div className="scroll-snap-child relative min-h-[520px] border-b border-slate-800 bg-slate-950/90 p-5 sm:p-8">
      <div className="mx-auto flex max-w-4xl flex-col gap-6 rounded-[2rem] border border-slate-800 bg-slate-900/95 p-6 shadow-2xl shadow-slate-950/30">
        <div className="space-y-4">
          <div className="flex items-center justify-between gap-3">
            <span className="rounded-full bg-slate-800 px-4 py-2 text-xs uppercase tracking-[0.2em] text-slate-400">Product video</span>
            <span className="text-sm font-semibold text-brand">RWF {product.price.toFixed(2)}</span>
          </div>
          <h2 className="text-3xl font-semibold text-white">{product.title}</h2>
          <p className="text-slate-400">{product.description}</p>
        </div>

        <div className="relative overflow-hidden rounded-[1.8rem] bg-slate-950 text-slate-100 shadow-inner shadow-slate-950/50">
          {product.videoUrl ? (
            <video
              className="h-[380px] w-full object-cover"
              src={product.videoUrl}
              poster={product.imageUrl}
              controls
              loop
              muted
            />
          ) : (
            <div className="flex h-[380px] items-center justify-center bg-slate-900/95 p-8 text-center text-slate-400">
              Video preview unavailable. Sellers can add short product videos for more engagement.
            </div>
          )}
        </div>

        <div className="flex flex-wrap items-center justify-between gap-4 rounded-3xl bg-slate-950/80 p-4 text-slate-300">
          <div>
            <p className="text-sm">Fast-swipe experience like TikTok, designed for product discovery.</p>
            <p className="text-sm text-slate-500">Scroll vertically to view the next item.</p>
          </div>
          <button className="rounded-full bg-brand px-5 py-3 text-sm font-semibold text-slate-950">Chat seller</button>
        </div>
      </div>
    </div>
  );
}
