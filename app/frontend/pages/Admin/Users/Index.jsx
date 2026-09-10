import { Link, router } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

function destroyUser(id, name) {
  if (window.confirm(`Delete user "${name}"? This cannot be undone.`)) router.delete(`/admin/users/${id}`)
}
function toggleRole(id, name) {
  if (window.confirm(`Toggle role for "${name}"?`)) router.patch(`/admin/users/${id}/toggle_role`)
}

function Pagination({ pagination, baseUrl }) {
  if (!pagination || pagination.total_pages <= 1) return null
  const { current_page, total_pages } = pagination
  const pages = []
  for (let i = 1; i <= total_pages; i++) pages.push(i)

  return (
    <nav className="flex items-center justify-center gap-1 mt-6" aria-label="Pagination">
      {current_page > 1 && (
        <Link href={`${baseUrl}?page=${current_page - 1}`} className="px-3 py-2 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-100 transition">Prev</Link>
      )}
      {pages.map((p) => (
        <Link key={p} href={`${baseUrl}?page=${p}`} className={`px-3 py-2 rounded-lg text-sm font-medium transition ${p === current_page ? "bg-blue-600 text-white" : "text-slate-600 hover:bg-slate-100"}`}>{p}</Link>
      ))}
      {current_page < total_pages && (
        <Link href={`${baseUrl}?page=${current_page + 1}`} className="px-3 py-2 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-100 transition">Next</Link>
      )}
    </nav>
  )
}

export default function Index({ users, admin_count, pagination }) {
  const isOnlyAdmin = (user) => user.role === "admin" && admin_count === 1
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Users</h1>
      <p className="text-slate-500 mb-4">Manage all registered users.</p>
      <Link href="/admin/users/new" className="inline-block rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold px-5 py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition mb-4">New user</Link>
      <div className="rounded-3xl overflow-hidden border border-slate-200 shadow-xl shadow-slate-200/40">
        <div className="overflow-x-auto">
          <table className="w-full text-left min-w-[560px]">
            <thead className="bg-slate-50 text-xs font-bold text-slate-500 uppercase tracking-wider">
              <tr><th className="px-3 py-2 whitespace-nowrap">Name</th><th className="px-3 py-2 whitespace-nowrap">Email</th><th className="px-3 py-2 whitespace-nowrap">Role</th><th className="px-3 py-2 whitespace-nowrap">Actions</th></tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {users.map((user) => (
                <tr key={user.id} className="hover:bg-slate-50/60 transition">
                  <td className="px-3 py-2 font-medium text-slate-900 whitespace-nowrap">{user.full_name}</td>
                  <td className="px-3 py-2 text-slate-600 max-w-[240px] truncate" title={user.email}>{user.email}</td>
                  <td className="px-3 py-2 whitespace-nowrap"><span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-100 capitalize">{user.role}</span></td>
                  <td className="px-3 py-2 whitespace-nowrap">
                    <div className="flex items-center gap-2 text-sm">
                      <Link href={`/admin/users/${user.id}`} className="underline text-emerald-700 hover:text-emerald-900">Profile</Link>
                      <Link href={`/admin/users/${user.id}/edit`} className="underline text-blue-700 hover:text-blue-900">Edit</Link>
                      <button onClick={() => toggleRole(user.id, user.full_name)} className="underline text-violet-700 hover:text-violet-900">Toggle role</button>
                      {isOnlyAdmin(user) ? (
                        <span className="text-slate-400 cursor-not-allowed" title="Cannot delete the only admin">Delete</span>
                      ) : (
                        <button onClick={() => destroyUser(user.id, user.full_name)} className="underline text-rose-600 hover:text-rose-800">Delete</button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      <Pagination pagination={pagination} baseUrl="/admin/users" />
    </div>
  )
}
Index.layout = (page) => <Layout>{page}</Layout>
