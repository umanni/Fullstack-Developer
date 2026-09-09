import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ email: "", password: "" })
  function submit(e) { e.preventDefault(); post("/session") }
  const set = (k) => (e) => setData(k, e.target.value)
  return (
    <div className="max-w-md mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Welcome back</h1>
      <p className="text-slate-500 mb-8">Sign in to manage your account.</p>
      <form onSubmit={submit} className="space-y-4">
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-slate-700 mb-1">Email</label>
          <input id="email" type="email" required autoFocus autoComplete="username" placeholder="you@example.com" value={data.email} onChange={set("email")} className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" />
          {errors.email && <p className="text-rose-600 text-sm mt-1">{errors.email}</p>}
        </div>
        <div>
          <label htmlFor="password" className="block text-sm font-medium text-slate-700 mb-1">Password</label>
          <input id="password" type="password" required autoComplete="current-password" placeholder="Enter your password" value={data.password} onChange={set("password")} className="w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition" />
          {errors.password && <p className="text-rose-600 text-sm mt-1">{errors.password}</p>}
        </div>
        <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition">Sign in</button>
      </form>
      <div className="mt-6 text-center text-sm text-slate-500">
        <a href="/passwords/new" className="underline hover:text-blue-700">Forgot password?</a>
        <span className="mx-2">·</span>
        <a href="/registration/new" className="underline hover:text-blue-700">Create account</a>
      </div>
    </div>
  )
}
New.layout = (page) => <Layout>{page}</Layout>
