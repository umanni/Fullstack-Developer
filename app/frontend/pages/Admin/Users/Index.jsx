import { Link, router } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

function destroyUser(id, name) {
  if (window.confirm(`Delete user "${name}"? This cannot be undone.`)) router.delete(`/admin/users/${id}`)
}
function toggleRole(id, name) {
  if (window.confirm(`Toggle role for "${name}"?`)) router.patch(`/admin/users/${id}/toggle_role`)
}

export default function Index({ users, admin_count }) {
  const isOnlyAdmin = (user) => user.role === "admin" && admin_count === 1
  return (
    <div className="max-w-5xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Users</h1>
      <p className="text-slate-500 mb-8">Manage all registered users.</p>
      <Link href="/admin/users/new" className="inline-block rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold px-5 py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition mb-6">New user</Link>
      <div className="rounded-3xl overflow-hidden border border-slate-200 shadow-xl shadow-slate-200/40">
        <table className="w-full text-left">
          <thead className="bg-slate-50 text-xs font-bold text-slate-500 uppercase tracking-wider">
            <tr><th className="px-6 py-4">Avatar</th><th>Name</th><th>Email</th><th>Role</th><th>Actions</th></tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {users.map((user) => (
              <tr key={user.id} className="hover:bg-slate-50/60 transition">
                <td className="px-6 py-4">
                  {user.has_avatar ? (
                    <span className="inline-flex items-center justify-center w-8 h-8 rounded-full bg-gradient-to-br from-blue-500 to-indigo-500 text-white text-xs font-bold shadow-md shadow-blue-500/20">✓</span>
                  ) : (
                    <span className="inline-flex items-center justify-center w-8 h-8 rounded-full bg-slate-200 text-slate-400 text-xs font-bold">—</span>
                  )}
                </td>
                <td className="px-6 py-4 font-medium text-slate-900">{user.full_name}</td>
                <td className="px-6 py-4 text-slate-600">{user.email}</td>
                <td className="px-6 py-4"><span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-100 capitalize">{user.role}</span></td>
                <td className="px-6 py-4 flex gap-3 text-sm">
                  <Link href={`/admin/users/${user.id}`} className="underline text-emerald-700 hover:text-emerald-900">Profile</Link>
                  <Link href={`/admin/users/${user.id}/edit`} className="underline text-blue-700 hover:text-blue-900">Edit</Link>
                  <button onClick={() => toggleRole(user.id, user.full_name)} className="underline text-violet-700 hover:text-violet-900">Toggle role</button>
                  {isOnlyAdmin(user) ? (
                    <span className="text-slate-400 cursor-not-allowed" title="Cannot delete the only admin">Delete</span>
                  ) : (
                    <button onClick={() => destroyUser(user.id, user.full_name)} className="underline text-rose-600 hover:text-rose-800">Delete</button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
Index.layout = (page) => <Layout>{page}</Layout>
