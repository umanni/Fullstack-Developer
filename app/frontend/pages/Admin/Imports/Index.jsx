import { Link } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

export default function Index({ imports }) {
  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Imports</h1>
      <p className="text-slate-500 mb-8">Asynchronous spreadsheet imports.</p>
      <Link href="/admin/user_imports/new" className="inline-block rounded-2xl bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white font-semibold px-5 py-3 shadow-lg shadow-violet-600/20 hover:shadow-violet-600/40 transition mb-6">New import</Link>
      <div className="rounded-3xl overflow-hidden border border-slate-200 shadow-xl shadow-slate-200/40">
        <div className="overflow-x-auto">
          <table className="w-full text-left min-w-[640px]">
            <thead className="bg-slate-50 text-xs font-bold text-slate-500 uppercase tracking-wider"><tr><th className="px-6 py-4 whitespace-nowrap">ID</th><th className="px-6 py-4 whitespace-nowrap">File Name</th><th className="px-6 py-4 whitespace-nowrap">Status</th><th className="px-6 py-4 whitespace-nowrap">Processed</th><th className="px-6 py-4 whitespace-nowrap">Failed</th><th className="px-6 py-4 whitespace-nowrap"></th></tr></thead>
            <tbody className="divide-y divide-slate-100">
              {imports.map((imp) => (
                <tr key={imp.id} className="hover:bg-slate-50/60 transition">
                  <td className="px-6 py-4 font-medium text-slate-900 whitespace-nowrap">{imp.id}</td>
                  <td className="px-6 py-4 text-slate-600 max-w-[240px] truncate" title={imp.file_name || ""}>{imp.file_name || "—"}</td>
                  <td className="px-6 py-4 whitespace-nowrap"><span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-100 capitalize">{imp.status}</span></td>
                  <td className="px-6 py-4 text-slate-600 whitespace-nowrap">{imp.processed_rows}</td>
                  <td className="px-6 py-4 text-slate-600 whitespace-nowrap">{imp.failed_rows}</td>
                  <td className="px-6 py-4 whitespace-nowrap"><Link href={`/admin/user_imports/${imp.id}`} className="underline text-blue-700 hover:text-blue-900">View</Link></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
Index.layout = (page) => <Layout>{page}</Layout>
