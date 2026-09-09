import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ email: "", password: "" })

  function submit(e) {
    e.preventDefault()
    post("/session")
  }

  return (
    <div className="mx-auto md:w-2/3 w-full">
      <h1 className="font-bold text-4xl">Sign in</h1>
      <form onSubmit={submit}>
        <div className="my-5">
          <input
            type="email" required autoFocus autoComplete="username"
            placeholder="Enter your email address" value={data.email}
            onChange={(e) => setData("email", e.target.value)}
            className="block shadow-sm rounded-md border border-gray-400 px-3 py-2 mt-2 w-full"
          />
          {errors.email && <p className="text-red-600 text-sm">{errors.email}</p>}
        </div>
        <div className="my-5">
          <input
            type="password" required autoComplete="current-password"
            placeholder="Enter your password" value={data.password}
            onChange={(e) => setData("password", e.target.value)}
            className="block shadow-sm rounded-md border border-gray-400 px-3 py-2 mt-2 w-full"
          />
          {errors.password && <p className="text-red-600 text-sm">{errors.password}</p>}
        </div>
        <div className="flex items-center gap-4">
          <button disabled={processing} className="rounded-md px-3.5 py-2.5 bg-blue-600 text-white font-medium">Sign in</button>
          <a href="/passwords/new" className="text-gray-700 underline text-sm">Forgot password?</a>
          <a href="/registration/new" className="text-blue-700 underline text-sm">Sign up</a>
        </div>
      </form>
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
