import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"
import { Field, PasswordHint, inputClass } from "../Shared/FormFields"

export default function Edit({ token }) {
  const { data, setData, put, processing, errors } = useForm({ password: "", password_confirmation: "" })
  function submit(e) {
    e.preventDefault()
    put(`/passwords/${token}`)
  }
  return (
    <div className="mx-auto md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Reset password</h1>
      <form onSubmit={submit}>
        <Field label="New password" htmlFor="password" error={errors.password} hint={<PasswordHint />}>
          <input id="password" className={inputClass} type="password" required placeholder="New password" value={data.password} onChange={(e) => setData("password", e.target.value)} />
        </Field>
        <Field label="Confirm password" htmlFor="password_confirmation" error={errors.password_confirmation}>
          <input id="password_confirmation" className={inputClass} type="password" required placeholder="Confirm" value={data.password_confirmation} onChange={(e) => setData("password_confirmation", e.target.value)} />
        </Field>
        <button disabled={processing} className="mt-4 rounded px-3 py-2 bg-blue-600 text-white disabled:opacity-50 disabled:cursor-not-allowed">Save</button>
      </form>
    </div>
  )
}

Edit.layout = (page) => <Layout>{page}</Layout>
