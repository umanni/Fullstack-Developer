import { useForm } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

const input = "w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition my-2"

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
    <form onSubmit={(e) => submitForm(e, () => submit(method, submitTo), method === "post" ? "Create this user?" : "Save changes to this user?")} className="space-y-4">
      <input className={input} placeholder="Full name" required value={data.user.full_name} onChange={set("full_name")} />
      {errors.full_name && <p className="text-rose-600 text-sm">{errors.full_name}</p>}
      <input className={input} type="email" placeholder="Email" required value={data.user.email} onChange={set("email")} />
      {errors.email && <p className="text-rose-600 text-sm">{errors.email}</p>}
      <input className={input} type="password" placeholder="Password" value={data.user.password} onChange={set("password")} />
      <input className={input} type="password" placeholder="Confirm" value={data.user.password_confirmation} onChange={set("password_confirmation")} />
      {errors.password && <p className="text-rose-600 text-sm">{errors.password}</p>}
      <select className={input} value={data.user.role} onChange={set("role")}>
        <option value="user">User</option>
        <option value="admin">Admin</option>
      </select>
      <input className={input} type="url" placeholder="Avatar URL https://…" value={data.user.avatar_url} onChange={set("avatar_url")} />
      {errors.avatar_url && <p className="text-rose-600 text-sm">{errors.avatar_url}</p>}
      <label className="block text-sm font-medium text-slate-700 mb-1">Avatar file
        <input type="file" accept="image/*" className="block w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition my-2" onChange={(e) => setData("user", { ...data.user, avatar_image: e.target.files[0] })} />
      </label>
      {errors.avatar_image && <p className="text-rose-600 text-sm">{errors.avatar_image}</p>}
      <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition">{submitLabel}</button>
    </form>
  )
}

export default function New() {
  return (
    <div className="max-w-xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">New user</h1>
      <p className="text-slate-500 mb-8">Create a new user account.</p>
      <UserForm submitTo="/admin/users" method="post" submitLabel="Create" />
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
