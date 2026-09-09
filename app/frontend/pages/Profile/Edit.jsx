import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function Edit({ user }) {
  const { data, setData, patch, processing, errors } = useForm({
    user: { full_name: user.full_name, email: user.email, avatar_url: user.avatar_url || "" },
  })
  function submit(e) {
    e.preventDefault()
    if (window.confirm("Save profile changes?")) patch("/profile")
  }
  const set = (k) => (e) => setData("user", { ...data.user, [k]: e.target.value })
  return (
    <div className="max-w-xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Edit Profile</h1>
      <p className="text-slate-500 mb-8">Update your account details.</p>
      <form onSubmit={submit} className="space-y-4">
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" required value={data.user.full_name} onChange={set("full_name")} />
        {errors.full_name && <p className="text-rose-600 text-sm">{errors.full_name}</p>}
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" type="email" required value={data.user.email} onChange={set("email")} />
        {errors.email && <p className="text-rose-600 text-sm">{errors.email}</p>}
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" type="url" placeholder="Avatar URL https://…" value={data.user.avatar_url} onChange={set("avatar_url")} />
        {errors.avatar_url && <p className="text-rose-600 text-sm">{errors.avatar_url}</p>}
        <label className="block text-sm font-medium text-slate-700 mb-1">Avatar file
          <input type="file" accept="image/*" className="block w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition my-2" onChange={(e) => setData("user", { ...data.user, avatar_image: e.target.files[0] })} />
        </label>
        {errors.avatar_image && <p className="text-rose-600 text-sm">{errors.avatar_image}</p>}
        <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition">Save</button>
      </form>
    </div>
  )
}
Edit.layout = (page) => <Layout>{page}</Layout>
