import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function New() {
  const { data, setData, post, processing } = useForm({ email: "" })
  function submit(e) {
    e.preventDefault()
    post("/passwords")
  }
  return (
    <div className="mx-auto md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Forgot your password?</h1>
      <form onSubmit={submit}>
        <input className="block shadow-sm rounded-md border px-3 py-2 mt-2 w-full" type="email" required placeholder="Enter your email address" value={data.email} onChange={(e) => setData("email", e.target.value)} />
        <button disabled={processing} className="mt-4 rounded-lg px-3.5 py-2.5 bg-blue-600 text-white font-medium">Email reset instructions</button>
      </form>
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
