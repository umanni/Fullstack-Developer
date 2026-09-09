import { Link, router } from "@inertiajs/react"
import { useEffect } from "react"
import Layout from "../../Shared/Layout"

export default function Show({ total_users, users_by_role }) {
  useEffect(() => {
    const id = setInterval(() => router.reload({ only: ["total_users", "users_by_role"] }), 3000)
    return () => clearInterval(id)
  }, [])

  return (
    <div className="mx-auto max-w-3xl w-full py-8">
      <h1 className="font-bold text-3xl mb-6">User Admin Dashboard</h1>
      <div className="mb-4 flex gap-3 text-sm">
        <Link href="/admin/users" className="underline">Users</Link>
        <Link href="/admin/user_imports" className="underline">Imports</Link>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div className="rounded-lg border p-4">
          <p className="text-sm text-gray-500">Total number of Users</p>
          <p className="text-3xl font-bold">{total_users}</p>
        </div>
        <div className="rounded-lg border p-4">
          <p className="text-sm text-gray-500">By Role</p>
          <ul>
            {Object.entries(users_by_role || {}).map(([role, count]) => (
              <li key={role}>{role}: {count}</li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  )
}

Show.layout = (page) => <Layout>{page}</Layout>
