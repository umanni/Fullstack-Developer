import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"
import { Field, FieldError, PasswordHint, inputClass } from "../Shared/FormFields"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ user: { full_name: "", email: "", password: "", password_confirmation: "" } })
  function submit(e) { e.preventDefault(); post("/registration") }
  const set = (k) => (e) => setData("user", { ...data.user, [k]: e.target.value })
  return (
    <div className="max-w-md mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Create account</h1>
      <p className="text-slate-500 mb-8">Join the modern fullstack platform.</p>
      <form onSubmit={submit} className="space-y-4">
        <Field label="Full name" htmlFor="full_name" error={errors.full_name}>
          <input id="full_name" className={inputClass} placeholder="Full name" required value={data.user.full_name} onChange={set("full_name")} />
        </Field>
        <Field label="Email" htmlFor="email" error={errors.email}>
          <input id="email" className={inputClass} type="email" placeholder="Email" required value={data.user.email} onChange={set("email")} />
        </Field>
        <Field label="Password" htmlFor="password" error={errors.password} hint={<PasswordHint />}>
          <input id="password" className={inputClass} type="password" placeholder="Password" required value={data.user.password} onChange={set("password")} />
        </Field>
        <Field label="Confirm password" htmlFor="password_confirmation">
          <input id="password_confirmation" className={inputClass} type="password" placeholder="Confirm password" required value={data.user.password_confirmation} onChange={set("password_confirmation")} />
        </Field>
        <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition disabled:opacity-50 disabled:cursor-not-allowed">Create account</button>
      </form>
    </div>
  )
}
New.layout = (page) => <Layout>{page}</Layout>
