import { Link, router } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

function destroyUser(id, name) {
  if (window.confirm(`Delete user "${name}"? This cannot be undone.`)) {
    router.delete(`/admin/users/${id}`)
  }
}

function toggleRole(id, name) {
  if (window.confirm(`Toggle role for "${name}"?`)) {
    router.patch(`/admin/users/${id}/toggle_role`)
  }
}

export default function Index({ users }) {
  return (
    <div className="mx-auto max-w-4xl w-full py-8">
      <h1 className="font-bold text-3xl mb-6">Users</h1>
      <Link href="/admin/users/new" className="rounded-md px-3 py-2 bg-blue-600 text-white">New user</Link>
      <table className="mt-4 w-full text-left">
        <thead><tr><th></th><th>Name</th><th>Email</th><th>Role</th><th></th></tr></thead>
        <tbody>
          {users.map((user) => (
            <tr key={user.id}>
              <td>{(user.avatar_image_url || user.avatar_url) && <img src={user.avatar_image_url || user.avatar_url} alt="" className="w-10 h-10 rounded-full object-cover" />}</td>
              <td>{user.full_name}</td>
              <td>{user.email}</td>
              <td>{user.role}</td>
              <td className="flex gap-2">
                <Link href={`/admin/users/${user.id}/edit`} className="underline">Edit</Link>
                <button onClick={() => toggleRole(user.id, user.full_name)} className="underline">Toggle role</button>
                <button onClick={() => destroyUser(user.id, user.full_name)} className="underline">Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

Index.layout = (page) => <Layout>{page}</Layout>
