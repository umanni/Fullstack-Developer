import { Link, router } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function Show({ user }) {
  function destroy(e) {
    e.preventDefault()
    if (window.confirm("Delete your profile? This cannot be undone.")) router.delete("/profile")
  }
  return (
    <div className="mx-auto max-w-xl w-full py-8">
      <h1 className="font-bold text-3xl mb-6">My Profile</h1>
      {user.avatar_url && !user.avatar_attached && (
        <img src={user.avatar_url} alt="" className="w-24 h-24 rounded-full object-cover mb-4" />
      )}
      <p><strong>Name:</strong> {user.full_name}</p>
      <p><strong>Email:</strong> {user.email}</p>
      <p><strong>Role:</strong> {user.role}</p>
      <div className="mt-4 flex gap-3">
        <Link href="/profile/edit" className="rounded bg-gray-200 px-3 py-2">Edit</Link>
        <button onClick={destroy} className="rounded bg-red-600 text-white px-3 py-2">Delete</button>
      </div>
    </div>
  )
}

Show.layout = (page) => <Layout>{page}</Layout>
