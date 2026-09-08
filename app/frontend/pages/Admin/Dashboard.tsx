import { Head, Link } from '@inertiajs/react'

import { Badge } from '@/components/Badge'
import { ButtonLink } from '@/components/Button'
import { EmptyState } from '@/components/EmptyState'
import { Icon } from '@/components/Icon'
import { PageHeader } from '@/components/PageHeader'
import { ProgressBar } from '@/components/ProgressBar'
import { useDashboardStatistics } from '@/hooks/useDashboardStatistics'
import { AppLayout } from '@/layouts/AppLayout'
import { formatDate, pluralize } from '@/lib/formatters'
import { routes } from '@/lib/routes'
import type { UserImport, UserStatistics } from '@/types'

function StatisticCard({
  label,
  value,
  icon,
  accent,
}: {
  label: string
  value: number
  icon: 'users' | 'shield' | 'user'
  accent: string
}) {
  return (
    <article className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-sm font-medium text-slate-500">{label}</p>
          <p className="mt-2 text-3xl font-bold tracking-tight text-slate-950 tabular-nums">
            {value.toLocaleString('en-US')}
          </p>
        </div>
        <span
          className={`grid size-11 place-items-center rounded-xl ${accent}`}
        >
          <Icon name={icon} />
        </span>
      </div>
    </article>
  )
}

export default function Dashboard({
  statistics: initialStatistics,
  recent_imports: recentImports,
}: {
  statistics: UserStatistics
  recent_imports: UserImport[]
}) {
  const statistics = useDashboardStatistics(initialStatistics)
  const adminShare =
    statistics.total === 0
      ? 0
      : Math.round((statistics.by_role.admin / statistics.total) * 100)

  return (
    <AppLayout>
      <Head title="Admin dashboard" />
      <PageHeader
        actions={
          <>
            <ButtonLink href={routes.newAdminImport} variant="secondary">
              <Icon className="size-4" name="upload" /> Import users
            </ButtonLink>
            <ButtonLink href={routes.newAdminUser}>
              <Icon className="size-4" name="plus" /> Add user
            </ButtonLink>
          </>
        }
        description="A live view of workspace membership and recent import activity."
        eyebrow="Administration"
        title="People overview"
      />

      <section
        aria-label="User statistics"
        className="mt-8 grid gap-4 sm:grid-cols-3"
      >
        <StatisticCard
          accent="bg-brand-50 text-brand-700"
          icon="users"
          label="Total users"
          value={statistics.total}
        />
        <StatisticCard
          accent="bg-violet-50 text-violet-700"
          icon="shield"
          label="Administrators"
          value={statistics.by_role.admin}
        />
        <StatisticCard
          accent="bg-sky-50 text-sky-700"
          icon="user"
          label="Standard users"
          value={statistics.by_role.user}
        />
      </section>

      <div className="mt-6 grid gap-6 xl:grid-cols-[minmax(0,1fr)_22rem]">
        <section className="rounded-2xl border border-slate-200 bg-white shadow-sm">
          <div className="flex items-center justify-between border-b border-slate-200 px-5 py-4 sm:px-6">
            <div>
              <h2 className="font-semibold text-slate-950">Recent imports</h2>
              <p className="mt-0.5 text-sm text-slate-500">
                The latest spreadsheet jobs.
              </p>
            </div>
            <ButtonLink href={routes.adminImports} size="sm" variant="ghost">
              View all
            </ButtonLink>
          </div>
          {recentImports.length === 0 ? (
            <div className="p-5 sm:p-6">
              <EmptyState
                description="Upload a CSV or XLSX file to create multiple users asynchronously."
                icon="import"
                title="No imports yet"
              />
            </div>
          ) : (
            <ul className="divide-y divide-slate-100">
              {recentImports.map((item) => (
                <li className="px-5 py-4 sm:px-6" key={item.id}>
                  <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                    <div className="min-w-0">
                      <Link
                        className="truncate text-sm font-semibold text-slate-900 hover:text-brand-700"
                        href={routes.adminImport(item.id)}
                      >
                        {item.file_name}
                      </Link>
                      <p className="mt-1 text-xs text-slate-500">
                        {formatDate(item.created_at)} ·{' '}
                        {pluralize(item.total_rows, 'row')}
                      </p>
                    </div>
                    <Badge value={item.status} />
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>

        <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-6">
          <h2 className="font-semibold text-slate-950">Role distribution</h2>
          <p className="mt-1 text-sm text-slate-500">
            Live membership breakdown.
          </p>
          <div className="mt-8">
            <div className="mb-3 flex items-end justify-between">
              <span className="text-sm font-medium text-slate-700">
                Administrator share
              </span>
              <span className="text-2xl font-bold text-slate-950 tabular-nums">
                {adminShare}%
              </span>
            </div>
            <ProgressBar value={adminShare} />
          </div>
          <dl className="mt-8 space-y-4 border-t border-slate-100 pt-6 text-sm">
            <div className="flex justify-between">
              <dt className="text-slate-500">Administrators</dt>
              <dd className="font-semibold tabular-nums">
                {statistics.by_role.admin}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-slate-500">Standard users</dt>
              <dd className="font-semibold tabular-nums">
                {statistics.by_role.user}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-slate-500">Last updated</dt>
              <dd className="text-right text-xs text-slate-600">
                {formatDate(statistics.generated_at)}
              </dd>
            </div>
          </dl>
        </section>
      </div>
    </AppLayout>
  )
}
