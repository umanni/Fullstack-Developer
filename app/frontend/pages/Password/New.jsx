import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"
import { Field, inputClass } from "../Shared/FormFields"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ email: "" })
  function submit(e) {
    e.preventDefault()
    post("/passwords")
  }
  return (
    <div className="mx-auto md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Forgot your password?</h1>
      <form onSubmit={submit}>
        <Field label="Email" htmlFor="email" error={errors.email}>
          <input id="email" className={inputClass} type="email" required placeholder="Enter your email address" value={data.email} onChange={(e) => setData("email", e.target.value)} />
        </Field>
        <button disabled={processing} className="mt-4 rounded-lg px-3.5 py-2.5 bg-blue-600 text-white font-medium disabled:opacity-50 disabled:cursor-not-allowed">Email reset instructions</button>
      </form>
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
