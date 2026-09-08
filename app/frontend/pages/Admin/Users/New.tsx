import { Head } from '@inertiajs/react'

import { PageHeader } from '@/components/PageHeader'
import { UserForm } from '@/components/UserForm'
import { AppLayout } from '@/layouts/AppLayout'
import { routes } from '@/lib/routes'

export default function NewUser() {
  return (
    <AppLayout>
      <Head title="Add user" />
      <PageHeader
        description="Create a workspace account and assign the appropriate level of access."
        eyebrow="Users"
        title="Add a user"
      />
      <div className="mt-8 max-w-3xl">
        <UserForm
          action={routes.adminUsers}
          allowRole
          cancelHref={routes.adminUsers}
          submitLabel="Create user"
        />
      </div>
    </AppLayout>
  )
}
