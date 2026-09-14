import { Head, Link } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import LocalTime from '@/components/LocalTime'
import StatCard from '@/components/StatCard'
import { useDashboardStream } from '@/hooks/useDashboardStream'
import type { DashboardStats } from '@/types'

/** Props from Admin::DashboardsController#show. */
type Props = { stats: DashboardStats }

const GENERATED_AT: Intl.DateTimeFormatOptions = { timeStyle: 'medium' }

export default function Dashboard({ stats }: Props) {
  useDashboardStream()

  return (
    <>
      <Head title="Admin dashboard" />

      <div className="flex flex-wrap items-baseline justify-between gap-3">
        <div className="flex flex-wrap items-baseline gap-3">
          <h1 className="text-2xl font-semibold tracking-tight">Admin dashboard</h1>
          <span className="text-xs text-slate-400">
            Updated <LocalTime dateTime={stats.generated_at} options={GENERATED_AT} />
          </span>
        </div>
        <Link
          href="/admin/users"
          className="rounded-md bg-slate-900 px-4 py-2 text-sm text-white hover:bg-slate-700"
        >
          Manage users
        </Link>
      </div>

      {/* A dl, not a div: StatCard renders a dt/dd pair. */}
      <dl className="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <StatCard label="Total users" value={stats.total} />
        {Object.entries(stats.by_role).map(([role, count]) => (
          <StatCard key={role} label={`${role}s`} value={count} />
        ))}
      </dl>
    </>
  )
}

Dashboard.layout = AppLayout
