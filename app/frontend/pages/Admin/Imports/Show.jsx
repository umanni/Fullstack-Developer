import { Link, router } from "@inertiajs/react"
import { useEffect, useState } from "react"
import Layout from "../../Shared/Layout"
import { subscribe } from "../../lib/cable"

export default function Show({ import: initial }) {
  const [imp, setImp] = useState(initial)
  useEffect(() => {
    const sub = subscribe("UserImportChannel", { id: initial.id }, (data) => setImp((prev) => ({ ...prev, ...data })))
    return () => sub.unsubscribe()
  }, [initial.id])
  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Import {imp.id}</h1>
      <p className="text-slate-500 mb-8">Live progress tracking.</p>
      <div className="rounded-3xl bg-gradient-to-br from-violet-50 to-fuchsia-50 border border-violet-100 p-8 shadow-xl shadow-violet-900/5">
        <div className="grid grid-cols-2 gap-6">
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Status</p><p className="text-2xl font-extrabold text-slate-900 capitalize">{imp.status}</p></div>
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Processed</p><p className="text-2xl font-extrabold text-slate-900">{imp.processed_rows}</p></div>
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Failed</p><p className="text-2xl font-extrabold text-slate-900">{imp.failed_rows}</p></div>
          <div><p className="text-xs font-bold text-violet-600 uppercase tracking-wider mb-1">Total</p><p className="text-2xl font-extrabold text-slate-900">{imp.total_rows}</p></div>
        </div>
      </div>
      <p className="mt-6"><Link href="/admin/user_imports" className="underline text-blue-700 hover:text-blue-900">Back</Link></p>
    </div>
  )
}
Show.layout = (page) => <Layout>{page}</Layout>
