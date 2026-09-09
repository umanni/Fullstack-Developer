import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({
    user: { full_name: "", email: "", password: "", password_confirmation: "" },
  })

  function submit(e) {
    e.preventDefault()
    post("/registration")
  }

  const set = (k) => (e) => setData("user", { ...data.user, [k]: e.target.value })

  return (
    <div className="mx-auto md:w-2/3 w-full py-8">
      <h1 className="font-bold text-4xl mb-6">Sign up</h1>
      <form onSubmit={submit}>
        <input className="block w-full rounded-md border px-3 py-2 my-2" placeholder="Full name" required value={data.user.full_name} onChange={set("full_name")} />
        {errors.full_name && <p className="text-red-600 text-sm">{errors.full_name}</p>}
        <input className="block w-full rounded-md border px-3 py-2 my-2" type="email" placeholder="Email" required value={data.user.email} onChange={set("email")} />
        {errors.email && <p className="text-red-600 text-sm">{errors.email}</p>}
        <input className="block w-full rounded-md border px-3 py-2 my-2" type="password" placeholder="Password" required value={data.user.password} onChange={set("password")} />
        <input className="block w-full rounded-md border px-3 py-2 my-2" type="password" placeholder="Confirm password" required value={data.user.password_confirmation} onChange={set("password_confirmation")} />
        {errors.password && <p className="text-red-600 text-sm">{errors.password}</p>}
        <button disabled={processing} className="rounded-md px-3.5 py-2.5 bg-blue-600 text-white font-medium">Create account</button>
      </form>
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
