import { Link } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

export default function Index({ users }) {
  return (
    <div className="mx-auto max-w-4xl w-full py-8">
      <h1 className="font-bold text-3xl mb-6">Users</h1>
      <Link href="/admin/users/new" className="rounded-md px-3 py-2 bg-blue-600 text-white">New user</Link>
      <table className="mt-4 w-full text-left">
        <thead><tr><th>Name</th><th>Email</th><th>Role</th><th></th></tr></thead>
        <tbody>
          {users.map((user) => (
            <tr key={user.id}>
              <td>{user.full_name}</td>
              <td>{user.email}</td>
              <td>{user.role}</td>
              <td className="flex gap-2">
                <Link href={`/admin/users/${user.id}/edit`} className="underline">Edit</Link>
                <Link href={`/admin/users/${user.id}/toggle_role`} method="patch" as="button" className="underline">Toggle role</Link>
                <Link href={`/admin/users/${user.id}`} method="delete" as="button" className="underline">Delete</Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

Index.layout = (page) => <Layout>{page}</Layout>
