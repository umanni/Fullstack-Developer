import { useForm } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

const input = "block w-full border rounded px-3 py-2 my-2"

export function UserForm({ user, submitTo, method, submitLabel }) {
  const { data, setData, submit, processing, errors } = useForm({
    user: {
      full_name: user?.full_name || "",
      email: user?.email || "",
      password: "",
      password_confirmation: "",
      role: user?.role || "user",
      avatar_url: user?.avatar_url || "",
    },
  })

  const set = (k) => (e) => setData("user", { ...data.user, [k]: e.target.value })

  function submitForm(e, submitFn, message) {
    e.preventDefault()
    if (window.confirm(message)) submitFn()
  }

  return (
    <form onSubmit={(e) => submitForm(e, () => submit(method, submitTo), method === "post" ? "Create this user?" : "Save changes to this user?")}>
      <input className={input} placeholder="Full name" required value={data.user.full_name} onChange={set("full_name")} />
      {errors.full_name && <p className="text-red-600 text-sm">{errors.full_name}</p>}
      <input className={input} type="email" placeholder="Email" required value={data.user.email} onChange={set("email")} />
      {errors.email && <p className="text-red-600 text-sm">{errors.email}</p>}
      <input className={input} type="password" placeholder="Password" value={data.user.password} onChange={set("password")} />
      <input className={input} type="password" placeholder="Confirm" value={data.user.password_confirmation} onChange={set("password_confirmation")} />
      <select className={input} value={data.user.role} onChange={set("role")}>
        <option value="user">user</option>
        <option value="admin">admin</option>
      </select>
      <input className={input} type="url" placeholder="Avatar URL https://…" value={data.user.avatar_url} onChange={set("avatar_url")} />
      {errors.avatar_url && <p className="text-red-600 text-sm">{errors.avatar_url}</p>}
      <label className="block text-sm">Avatar file
        <input type="file" accept="image/*" className="block w-full my-2" onChange={(e) => setData("user", { ...data.user, avatar_image: e.target.files[0] })} />
      </label>
      {errors.avatar_image && <p className="text-red-600 text-sm">{errors.avatar_image}</p>}
      <button disabled={processing} className="bg-blue-600 text-white rounded px-3 py-2">{submitLabel}</button>
    </form>
  )
}

export default function New() {
  return (
    <div className="mx-auto max-w-xl py-8">
      <h1 className="font-bold text-2xl mb-4">New user</h1>
      <UserForm submitTo="/admin/users" method="post" submitLabel="Create" />
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
