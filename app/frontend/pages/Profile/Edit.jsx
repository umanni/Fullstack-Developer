import { router } from "@inertiajs/react"
import { useForm } from "@inertiajs/react"
import Layout from "../Shared/Layout"
import { Field, inputClass } from "../Shared/FormFields"

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
    <div className="max-w-xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Edit Profile</h1>
      <p className="text-slate-500 mb-8">Update your account details.</p>
      <form onSubmit={submit} className="space-y-4">
        <Field label="Full name" htmlFor="full_name" error={errors.full_name}>
          <input id="full_name" className={inputClass} required value={data.user.full_name} onChange={set("full_name")} />
        </Field>
        <Field label="Email" htmlFor="email" error={errors.email}>
          <input id="email" className={inputClass} type="email" required value={data.user.email} onChange={set("email")} />
        </Field>
        <Field label="Avatar URL" htmlFor="avatar_url" error={errors.avatar_url}>
          <input id="avatar_url" className={inputClass} type="url" placeholder="https://example.com/avatar.jpg" value={data.user.avatar_url} onChange={set("avatar_url")} />
        </Field>
        <Field label="Avatar file" htmlFor="avatar_image" error={errors.avatar_image}>
          <input id="avatar_image" type="file" accept="image/*" className={`block w-full ${inputClass} my-2`} onChange={(e) => setData("user", { ...data.user, avatar_image: e.target.files[0] })} />
        </Field>
        <button disabled={processing} className="w-full rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-semibold py-3 shadow-lg shadow-blue-600/20 hover:shadow-blue-600/40 transition disabled:opacity-50 disabled:cursor-not-allowed">Save</button>
        <button type="button" onClick={() => { if (window.confirm("Remove avatar image?")) router.delete("/profile/remove_avatar") }} className="w-full rounded-xl bg-rose-600 text-white font-semibold py-3 shadow-lg shadow-rose-600/20 hover:shadow-rose-600/40 transition mt-2">Remove avatar</button>
      </form>
    </div>
  )
}
Edit.layout = (page) => <Layout>{page}</Layout>
