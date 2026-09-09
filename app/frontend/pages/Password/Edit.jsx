import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function Edit({ token }) {
  const { data, setData, put, processing } = useForm({ password: "", password_confirmation: "" })
  function submit(e) {
    e.preventDefault()
    put(`/passwords/${token}`)
  }
  return (
    <div className="mx-auto md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Reset password</h1>
      <form onSubmit={submit}>
        <input className="block border rounded px-3 py-2 mt-2 w-full" type="password" required placeholder="New password" value={data.password} onChange={(e) => setData("password", e.target.value)} />
        <input className="block border rounded px-3 py-2 mt-2 w-full" type="password" required placeholder="Confirm" value={data.password_confirmation} onChange={(e) => setData("password_confirmation", e.target.value)} />
        <button disabled={processing} className="mt-4 rounded px-3 py-2 bg-blue-600 text-white">Save</button>
      </form>
    </div>
  )
}

Edit.layout = (page) => <Layout>{page}</Layout>
