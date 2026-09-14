import { Head, Link, router } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import Avatar from '@/components/Avatar'
import LocalTime from '@/components/LocalTime'
import RoleBadge from '@/components/RoleBadge'
import type { User } from '@/types'

/** Props from Admin::UsersController#show. */
type Props = { user: User }

const JOINED_AT: Intl.DateTimeFormatOptions = { dateStyle: 'long' }

export default function Show({ user }: Props) {
  const destroy = () => {
    if (!window.confirm(`Delete ${user.full_name}? This cannot be undone.`)) return
    router.delete(`/admin/users/${user.id}`)
  }

  return (
    <>
      <Head title={user.full_name} />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex min-w-0 flex-wrap items-center gap-3">
          <Avatar user={user} size="md" />
          <h1 className="text-2xl font-semibold tracking-tight wrap-anywhere">{user.full_name}</h1>
          <RoleBadge role={user.role} />
        </div>
        <Link href="/admin/users" className="text-sm text-slate-600 hover:underline">
          Back to users
        </Link>
      </div>

      <dl className="mt-6 max-w-lg divide-y divide-slate-100 rounded-lg border border-slate-200 bg-white text-sm">
        <div className="flex justify-between gap-4 px-4 py-3">
          <dt className="text-slate-500">Email</dt>
          <dd className="min-w-0 text-right wrap-anywhere">{user.email_address}</dd>
        </div>
        <div className="flex justify-between gap-4 px-4 py-3">
          <dt className="text-slate-500">Role</dt>
          <dd className="capitalize">{user.role}</dd>
        </div>
        <div className="flex justify-between gap-4 px-4 py-3">
          <dt className="text-slate-500">Joined</dt>
          <dd>
            <LocalTime dateTime={user.created_at} options={JOINED_AT} />
          </dd>
        </div>
      </dl>

      <div className="mt-6 flex items-center gap-4 text-sm">
        <Link
          href={`/admin/users/${user.id}/edit`}
          className="rounded-md bg-slate-900 px-4 py-2 text-white hover:bg-slate-700"
        >
          Edit user
        </Link>
        <button type="button" onClick={destroy} className="text-red-600 hover:underline">
          Delete user
        </button>
      </div>
    </>
  )
}

Show.layout = AppLayout
