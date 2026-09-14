import { Head, Link, router } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import UserForm from '@/components/UserForm'
import type { User } from '@/types'

/** Props from ProfilesController#edit. */
type Props = { user: User }

export default function ProfileEdit({ user }: Props) {
  const destroy = () => {
    if (!window.confirm('Delete your account permanently? This cannot be undone.')) return
    router.delete('/profile')
  }

  return (
    <>
      <Head title="Your profile" />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">Your profile</h1>
        <Link href="/profile" className="text-sm text-slate-600 hover:underline">
          Back to profile
        </Link>
      </div>

      {/*
        No `roles` prop: members cannot see or submit a role field. UserPolicy#permitted_attributes
        drops `role` for owners regardless, so this is presentation, not the enforcement point.
      */}
      <div className="mt-6">
        <UserForm user={user} action="/profile" method="patch" submitLabel="Save changes" />
      </div>

      <button
        type="button"
        onClick={destroy}
        className="mt-10 text-sm text-red-600 hover:underline"
      >
        Delete my account
      </button>
    </>
  )
}

ProfileEdit.layout = AppLayout
