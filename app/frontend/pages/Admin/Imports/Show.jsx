import { Link } from "@inertiajs/react"
import { useEffect, useState } from "react"
import Layout from "../../Shared/Layout"
import { subscribe } from "../../../lib/cable"

export default function Show({ import: initial }) {
  const [imp, setImp] = useState(initial)
  useEffect(() => {
    const sub = subscribe("UserImportChannel", { id: initial.id }, (data) => setImp((prev) => ({ ...prev, ...data })))
    return () => sub.unsubscribe()
  }, [initial.id])

  const pct = imp.progress_percent || 0

  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Import {imp.id}</h1>
      <p className="text-slate-500 mb-8">Live progress tracking.</p>
      <div className="rounded-3xl bg-gradient-to-br from-violet-50 to-fuchsia-50 border border-violet-100 p-8 shadow-xl shadow-violet-900/5">
        <div className="grid grid-cols-2 gap-6 mb-6">
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Status</p><p className="text-2xl font-extrabold text-slate-900 capitalize">{imp.status}</p></div>
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Processed</p><p className="text-2xl font-extrabold text-slate-900">{imp.processed_rows}</p></div>
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Failed</p><p className="text-2xl font-extrabold text-slate-900">{imp.failed_rows}</p></div>
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Total</p><p className="text-2xl font-extrabold text-slate-900">{imp.total_rows}</p></div>
        </div>
        <div className="w-full bg-white/60 rounded-full h-4 overflow-hidden">
          <div className="h-full bg-gradient-to-r from-violet-500 to-fuchsia-500 transition-all duration-500" style={{ width: `${pct}%` }} />
        </div>
        <p className="mt-2 text-sm font-semibold text-violet-700">{pct}% complete</p>
      </div>

      {imp.row_errors && imp.row_errors.length > 0 && (
        <div className="mt-6 rounded-3xl border border-rose-200 bg-rose-50 p-6 shadow-xl shadow-rose-900/5">
          <h2 className="text-lg font-bold text-rose-800 mb-3">Row errors ({imp.row_errors.length})</h2>
          <ul className="space-y-2">
            {imp.row_errors.map((err, i) => (
              <li key={i} className="text-sm text-rose-700 bg-white/70 rounded-xl px-4 py-2 border border-rose-100">
                <span className="font-semibold">Row {err.row}</span> — {err.email || "(blank)"}: {err.error}
              </li>
            ))}
          </ul>
        </div>
      )}

      <p className="mt-6"><Link href="/admin/user_imports" className="underline text-blue-700 hover:text-blue-900">Back</Link></p>
    </div>
  )
}
Show.layout = (page) => <Layout>{page}</Layout>