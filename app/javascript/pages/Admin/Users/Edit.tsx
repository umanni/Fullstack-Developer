import { Head, Link } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import UserForm from '@/components/UserForm'
import type { User, UserRole } from '@/types'

/** Props from Admin::UsersController#edit. */
type Props = { user: User; roles: UserRole[] }

export default function Edit({ user, roles }: Props) {
  return (
    <>
      <Head title={`Edit ${user.full_name}`} />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">Edit {user.full_name}</h1>
        <Link href="/admin/users" className="text-sm text-slate-600 hover:underline">
          Back to users
        </Link>
      </div>

      <div className="mt-6">
        <UserForm
          user={user}
          roles={roles}
          action={`/admin/users/${user.id}`}
          method="patch"
          submitLabel="Save changes"
        />
      </div>
    </>
  )
}

Edit.layout = AppLayout
