import { Head, Link } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import UserForm from '@/components/UserForm'
import type { UserRole } from '@/types'

/** Props from Admin::UsersController#new. */
type Props = { roles: UserRole[] }

export default function New({ roles }: Props) {
  return (
    <>
      <Head title="New user" />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">New user</h1>
        <Link href="/admin/users" className="text-sm text-slate-600 hover:underline">
          Back to users
        </Link>
      </div>

      <div className="mt-6">
        <UserForm roles={roles} action="/admin/users" method="post" submitLabel="Create user" />
      </div>
    </>
  )
}

New.layout = AppLayout
