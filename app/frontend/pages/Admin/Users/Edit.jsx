import Layout from "../../Shared/Layout"
import { UserForm } from "./New"

export default function Edit({ user }) {
  return (
    <div className="mx-auto max-w-xl py-8">
      <h1 className="font-bold text-2xl mb-4">Edit user</h1>
      <UserForm user={user} submitTo={`/admin/users/${user.id}`} method="patch" submitLabel="Save" />
    </div>
  )
}

Edit.layout = (page) => <Layout>{page}</Layout>
