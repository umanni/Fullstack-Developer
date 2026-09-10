import { useForm } from "@inertiajs/react"
import Layout from "../../Shared/Layout"
import { Field, PasswordHint, inputClass } from "../../Shared/FormFields"

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
      <Field label="Full name" htmlFor="full_name" error={errors.full_name}>
        <input id="full_name" className={inputClass} placeholder="Full name" required value={data.user.full_name} onChange={set("full_name")} />
      </Field>
      <Field label="Email" htmlFor="email" error={errors.email}>
        <input id="email" className={inputClass} type="email" placeholder="Email" required value={data.user.email} onChange={set("email")} />
      </Field>
      <Field label="Password" htmlFor="password" error={errors.password} hint={<PasswordHint />}>
        <input id="password" className={inputClass} type="password" placeholder="Password" value={data.user.password} onChange={set("password")} />
      </Field>
      <Field label="Confirm password" htmlFor="password_confirmation" error={errors.password_confirmation}>
        <input id="password_confirmation" className={inputClass} type="password" placeholder="Confirm" value={data.user.password_confirmation} onChange={set("password_confirmation")} />
      </Field>
      <Field label="Role" htmlFor="role">
        <select id="role" className={inputClass} value={data.user.role} onChange={set("role")}>
          <option value="user">User</option>
          <option value="admin">Admin</option>
        </select>
      </Field>
      <Field label="Avatar URL" htmlFor="avatar_url" error={errors.avatar_url}>
        <input id="avatar_url" className={inputClass} type="url" placeholder="Avatar URL https://..." value={data.user.avatar_url} onChange={set("avatar_url")} />
      </Field>
      <Field label="Avatar file" htmlFor="avatar_image" error={errors.avatar_image}>
        <input id="avatar_image" type="file" accept="image/*" className={`block w-full ${inputClass} my-2`} onChange={(e) => setData("user", { ...data.user, avatar_image: e.target.files[0] })} />
      </Field>
      <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition disabled:opacity-50 disabled:cursor-not-allowed">{submitLabel}</button>
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
