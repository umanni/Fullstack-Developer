import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"
import { Field, inputClass } from "../Shared/FormFields"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ email: "", password: "" })
  function submit(e) { e.preventDefault(); post("/session") }
  const set = (k) => (e) => setData(k, e.target.value)
  return (
    <div className="max-w-md mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Welcome back</h1>
      <p className="text-slate-500 mb-8">Sign in to manage your account.</p>
      <form onSubmit={submit} className="space-y-4">
        <Field label="Email" htmlFor="email" error={errors.email}>
          <input id="email" type="email" required autoFocus autoComplete="username" placeholder="you@example.com" value={data.email} onChange={set("email")} className={inputClass} />
        </Field>
        <Field label="Password" htmlFor="password" error={errors.password}>
          <input id="password" type="password" required autoComplete="current-password" placeholder="Enter your password" value={data.password} onChange={set("password")} className={inputClass} />
        </Field>
        <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition disabled:opacity-50 disabled:cursor-not-allowed">Sign in</button>
      </form>
      <div className="mt-6 text-center text-sm text-slate-500">
        <a href="/passwords/new" className="underline hover:text-blue-700">Forgot password?</a>
        <span className="mx-2">&middot;</span>
        <a href="/registration/new" className="underline hover:text-blue-700">Create account</a>
      </div>
    </div>
  )
}
New.layout = (page) => <Layout>{page}</Layout>
