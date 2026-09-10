import { Link } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function Show({ user }) {
  return (
    <div className="max-w-xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">My Profile</h1>
      <p className="text-slate-500 mb-8">Your account details and preferences.</p>
      <div className="flex items-center gap-6 mb-8">
        <div className="w-24 h-24 rounded-3xl overflow-hidden shadow-xl shadow-slate-200 ring-4 ring-white bg-gradient-to-br from-blue-100 to-indigo-100 flex items-center justify-center">
          {(user.avatar_attached ? user.avatar_image_url : user.avatar_url) ? (
            <img src={user.avatar_attached ? user.avatar_image_url : user.avatar_url} alt={user.full_name} className="w-full h-full object-cover" />
          ) : (
            <span className="text-3xl font-bold text-blue-600">{user.full_name?.charAt(0)}</span>
          )}
        </div>
        <div>
          <h2 className="text-2xl font-bold text-slate-900">{user.full_name}</h2>
          <p className="text-slate-500">{user.email}</p>
          <span className="inline-block mt-2 px-3 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-100">{user.role}</span>
        </div>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <Link href="/profile/edit" className="text-center px-5 py-3 rounded-2xl bg-slate-900 text-white font-medium hover:bg-slate-800 transition shadow-lg shadow-slate-900/10">Edit profile</Link>
        <Link href="/profile" method="delete" as="button" data={{ confirm: "Delete your profile? This cannot be undone." }} className="text-center px-5 py-3 rounded-2xl bg-rose-600 text-white font-medium hover:bg-rose-700 transition shadow-lg shadow-rose-600/10">Delete account</Link>
      </div>
    </div>
  )
}
Show.layout = (page) => <Layout>{page}</Layout>
