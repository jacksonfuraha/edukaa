export default function AddressFields({ form, onChange }) {
  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <label className="space-y-2 text-sm text-slate-300">
        Country
        <input required name="country" value={form.country} onChange={onChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
      </label>
      <label className="space-y-2 text-sm text-slate-300">
        Province
        <input required name="province" value={form.province} onChange={onChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
      </label>
      <label className="space-y-2 text-sm text-slate-300">
        District
        <input required name="district" value={form.district} onChange={onChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
      </label>
      <label className="space-y-2 text-sm text-slate-300">
        Sector
        <input required name="sector" value={form.sector} onChange={onChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
      </label>
      <label className="space-y-2 text-sm text-slate-300">
        Cell
        <input required name="cell" value={form.cell} onChange={onChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
      </label>
      <label className="space-y-2 text-sm text-slate-300">
        Village
        <input required name="village" value={form.village} onChange={onChange} className="w-full rounded-3xl border border-slate-800 bg-slate-950 px-4 py-3 text-slate-100" />
      </label>
    </div>
  );
}
