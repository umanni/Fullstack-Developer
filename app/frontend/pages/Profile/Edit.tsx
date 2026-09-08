import { Head } from '@inertiajs/react'

import { PageHeader } from '@/components/PageHeader'
import { UserForm } from '@/components/UserForm'
import { AppLayout } from '@/layouts/AppLayout'
import { routes } from '@/lib/routes'
import type { User } from '@/types'

export default function ProfileEdit({ profile }: { profile: User }) {
  return (
    <AppLayout>
      <Head title="Edit profile" />
      <PageHeader
        description="Keep your account details and profile image up to date."
        eyebrow="Account"
        title="Edit profile"
      />
      <div className="mt-8 max-w-3xl">
        <UserForm
          action={routes.profile}
          cancelHref={routes.profile}
          submitLabel="Save changes"
          user={profile}
        />
      </div>
    </AppLayout>
  )
}
