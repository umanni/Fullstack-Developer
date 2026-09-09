import { Link, router } from "@inertiajs/react"
import { useEffect, useState } from "react"
import Layout from "../../Shared/Layout"
import { subscribe } from "../../../lib/cable"

export default function Show({ total_users, users_by_role }) {
  const [counts, setCounts] = useState({ total_users, users_by_role })
  useEffect(() => {
    const sub = subscribe("DashboardChannel", {}, (data) => setCounts(data))
    return () => sub.unsubscribe()
  }, [])
  return (
    <div className="max-w-5xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Dashboard</h1>
      <p className="text-slate-500 mb-8">Real-time user statistics.</p>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="rounded-3xl bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-100 p-8 shadow-xl shadow-blue-900/5">
          <p className="text-sm font-medium text-blue-600 mb-2">Total Users</p>
          <p className="text-5xl font-extrabold text-slate-900">{counts.total_users}</p>
        </div>
        <div className="rounded-3xl bg-gradient-to-br from-emerald-50 to-teal-50 border border-emerald-100 p-8 shadow-xl shadow-emerald-900/5">
          <p className="text-sm font-medium text-emerald-600 mb-4">By Role</p>
          <ul className="space-y-2">
            {Object.entries(counts.users_by_role || {}).map(([role, count]) => (
              <li key={role} className="flex justify-between text-lg font-semibold text-slate-800"><span className="capitalize">{role}</span><span className="text-emerald-700">{count}</span></li>
            ))}
          </ul>
        </div>
      </div>
      <div className="mt-8 flex gap-3">
        <Link href="/admin/users" className="px-5 py-3 rounded-2xl bg-slate-900 text-white font-medium hover:bg-slate-800 transition shadow-lg shadow-slate-900/10">Manage users</Link>
        <Link href="/admin/user_imports" className="px-5 py-3 rounded-2xl bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white font-medium hover:from-violet-700 hover:to-fuchsia-700 transition shadow-lg shadow-violet-600/20">Imports</Link>
      </div>
    </div>
  )
}
Show.layout = (page) => <Layout>{page}</Layout>
