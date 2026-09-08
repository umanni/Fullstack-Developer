import { Head, router } from '@inertiajs/react'

import { Avatar } from '@/components/Avatar'
import { Badge } from '@/components/Badge'
import { Button, ButtonLink } from '@/components/Button'
import { Icon } from '@/components/Icon'
import { PageHeader } from '@/components/PageHeader'
import { AppLayout } from '@/layouts/AppLayout'
import { formatDate } from '@/lib/formatters'
import { routes } from '@/lib/routes'
import type { User } from '@/types'

export default function ProfileShow({ profile }: { profile: User }) {
  const removeProfile = () => {
    if (
      window.confirm(
        'Delete your profile permanently? This action cannot be undone.',
      )
    ) {
      router.delete(routes.profile)
    }
  }

  return (
    <AppLayout>
      <Head title="My profile" />
      <PageHeader
        actions={
          <ButtonLink href={routes.editProfile}>
            <Icon className="size-4" name="edit" /> Edit profile
          </ButtonLink>
        }
        description="View and manage your personal account information."
        eyebrow="Account"
        title="My profile"
      />

      <div className="mt-8 overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
        <div className="h-28 bg-gradient-to-r from-brand-950 via-brand-800 to-brand-600 sm:h-36 mb-4" />
        <div className="px-5 pb-7 sm:px-8">
          <div className="-mt-12 flex flex-col items-start gap-4 sm:-mt-10 sm:flex-row sm:items-end">
            <Avatar
              name={profile.full_name}
              size="xl"
              src={profile.avatar_url}
            />
            <div className="min-w-0 flex-1 pb-1">
              <div className="flex flex-wrap items-center gap-3">
                <h2 className="text-2xl font-bold tracking-tight text-slate-950">
                  {profile.full_name}
                </h2>
                <Badge value={profile.role} />
              </div>
              <p className="mt-1 text-sm text-slate-500">{profile.email}</p>
            </div>
          </div>

          <dl className="mt-8 grid gap-5 border-t border-slate-200 pt-7 sm:grid-cols-2">
            <div>
              <dt className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                Email address
              </dt>
              <dd className="mt-1.5 text-sm font-medium text-slate-900">
                {profile.email}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                Member since
              </dt>
              <dd className="mt-1.5 text-sm font-medium text-slate-900">
                {formatDate(profile.created_at, {
                  dateStyle: 'long',
                  timeStyle: undefined,
                })}
              </dd>
            </div>
          </dl>
        </div>
      </div>

      <section className="mt-8 rounded-2xl border border-rose-200 bg-white p-5 sm:flex sm:items-center sm:justify-between sm:gap-8 sm:p-7">
        <div>
          <h2 className="font-semibold text-slate-950">Delete account</h2>
          <p className="mt-1 text-sm leading-6 text-slate-600">
            Permanently remove your profile and active sessions. This cannot be
            reversed.
          </p>
        </div>
        <Button
          className="mt-4 shrink-0 sm:mt-0"
          onClick={removeProfile}
          variant="danger"
        >
          <Icon className="size-4" name="trash" /> Delete profile
        </Button>
      </section>
    </AppLayout>
  )
}
