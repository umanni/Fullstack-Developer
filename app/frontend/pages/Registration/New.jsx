import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ user: { full_name: "", email: "", password: "", password_confirmation: "" } })
  function submit(e) { e.preventDefault(); post("/registration") }
  const set = (k) => (e) => setData("user", { ...data.user, [k]: e.target.value })
  return (
    <div className="max-w-md mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Create account</h1>
      <p className="text-slate-500 mb-8">Join the modern fullstack platform.</p>
      <form onSubmit={submit} className="space-y-4">
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" placeholder="Full name" required value={data.user.full_name} onChange={set("full_name")} />
        {errors.full_name && <p className="text-rose-600 text-sm">{errors.full_name}</p>}
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" type="email" placeholder="Email" required value={data.user.email} onChange={set("email")} />
        {errors.email && <p className="text-rose-600 text-sm">{errors.email}</p>}
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" type="password" placeholder="Password" required value={data.user.password} onChange={set("password")} />
        <input className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" type="password" placeholder="Confirm password" required value={data.user.password_confirmation} onChange={set("password_confirmation")} />
        {errors.password && <p className="text-rose-600 text-sm">{errors.password}</p>}
        <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition">Create account</button>
      </form>
    </div>
  )
}
New.layout = (page) => <Layout>{page}</Layout>
