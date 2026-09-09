import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"

export default function Edit({ user }) {
  const { data, setData, patch, processing, errors } = useForm({
    user: { full_name: user.full_name, email: user.email, avatar_url: user.avatar_url || "" },
  })

  function submit(e) {
    e.preventDefault()
    patch("/profile")
  }

  const set = (k) => (e) => setData("user", { ...data.user, [k]: e.target.value })

  return (
    <div className="mx-auto max-w-xl w-full py-8">
      <h1 className="font-bold text-3xl mb-6">Edit Profile</h1>
      <form onSubmit={submit}>
        <input className="block w-full rounded-md border px-3 py-2 my-2" required value={data.user.full_name} onChange={set("full_name")} />
        {errors.full_name && <p className="text-red-600 text-sm">{errors.full_name}</p>}
        <input className="block w-full rounded-md border px-3 py-2 my-2" type="email" required value={data.user.email} onChange={set("email")} />
        {errors.email && <p className="text-red-600 text-sm">{errors.email}</p>}
        <input className="block w-full rounded-md border px-3 py-2 my-2" type="url" placeholder="Avatar URL https://…" value={data.user.avatar_url} onChange={set("avatar_url")} />
        {errors.avatar_url && <p className="text-red-600 text-sm">{errors.avatar_url}</p>}
        <button disabled={processing} className="rounded-md px-3.5 py-2.5 bg-blue-600 text-white font-medium">Save</button>
      </form>
    </div>
  )
}

Edit.layout = (page) => <Layout>{page}</Layout>
