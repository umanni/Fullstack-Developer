import Layout from "../../Shared/Layout"
import { UserForm } from "./New"

export default function Edit({ user }) {
  return (
    <div className="max-w-xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Edit user</h1>
      <p className="text-slate-500 mb-8">Update user details.</p>
      <UserForm user={user} submitTo={`/admin/users/${user.id}`} method="patch" submitLabel="Save" />
    </div>
  )
}

Edit.layout = (page) => <Layout>{page}</Layout>
