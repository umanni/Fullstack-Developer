import { Head } from '@inertiajs/react'

import { PageHeader } from '@/components/PageHeader'
import { UserForm } from '@/components/UserForm'
import { AppLayout } from '@/layouts/AppLayout'
import { routes } from '@/lib/routes'
import type { User } from '@/types'

export default function EditUser({ user }: { user: User }) {
  return (
    <AppLayout>
      <Head title={`Edit ${user.full_name}`} />
      <PageHeader
        description="Update profile details. Role changes are intentionally handled from the user list with additional safeguards."
        eyebrow="Users"
        title={`Edit ${user.full_name}`}
      />
      <div className="mt-8 max-w-3xl">
        <UserForm
          action={routes.adminUser(user.id)}
          cancelHref={routes.adminUsers}
          submitLabel="Save changes"
          user={user}
        />
      </div>
    </AppLayout>
  )
}
