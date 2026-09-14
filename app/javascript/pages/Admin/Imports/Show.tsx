import { useEffect, useRef } from 'react'
import { Head, Link, router } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import { useLocaleFormat } from '@/hooks/useLocaleFormat'
import { getConsumer } from '@/lib/cable'
import type { Import } from '@/types'

/** Props from Admin::ImportsController#show. */
type Props = { import: Import }

export default function Show({ import: record }: Props) {
  const finished = record.finished
  const pending = useRef<number | null>(null)
  const format = useLocaleFormat()

  useEffect(() => {
    if (finished) return

    const refresh = () => router.reload({ only: ['import'] })

    const subscription = getConsumer().subscriptions.create(
      { channel: 'ImportChannel', id: record.id },
      {
        connected: refresh,
        received() {
          if (pending.current) return
          pending.current = window.setTimeout(() => {
            pending.current = null
            refresh()
          }, 300)
        },
      },
    )

    return () => {
      if (pending.current) clearTimeout(pending.current)
      // Reset too: a stale id left here would make the next subscription's
      // received() bail out on every message.
      pending.current = null
      subscription.unsubscribe()
    }
  }, [record.id, finished])

  return (
    <>
      <Head title={`Import ${record.filename}`} />

      <div className="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">{record.filename}</h1>
          <p className="mt-1 text-sm text-slate-500">Status: {record.status}</p>
        </div>
        <div className="flex items-center gap-4 text-sm">
          <Link href="/admin/imports" className="text-slate-600 hover:underline">
            All imports
          </Link>
          <Link href="/admin/users" className="text-slate-600 hover:underline">
            Back to users
          </Link>
        </div>
      </div>

      <div className="mt-6 max-w-xl">
        <div
          role="progressbar"
          aria-valuenow={record.progress}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-label="Import progress"
          className="h-3 overflow-hidden rounded-full bg-slate-200"
        >
          <div
            className="h-full bg-slate-900 transition-[width] duration-300 ease-out"
            style={{ width: `${record.progress}%` }}
          />
        </div>
        <p className="mt-2 text-sm tabular-nums text-slate-600">
          {format.number(record.processed_rows)} of {format.number(record.total_rows)} rows (
          {record.progress}%)
        </p>
      </div>

      <dl className="mt-8 grid max-w-xl grid-cols-3 gap-4">
        {[
          ['Created', record.created_count],
          ['Skipped', record.skipped_count],
          ['Failed', record.failed_count],
        ].map(([label, count]) => (
          <div key={label as string} className="rounded-lg border border-slate-200 bg-white p-4">
            <dt className="text-xs uppercase tracking-wide text-slate-500">{label}</dt>
            <dd className="mt-1 text-2xl font-semibold tabular-nums">{count as number}</dd>
          </div>
        ))}
      </dl>

      {record.failure_reason && (
        <p className="mt-6 rounded-md bg-red-50 px-4 py-3 text-sm text-red-800">
          {record.failure_reason}
        </p>
      )}

      {record.error_report.length > 0 && (
        <section className="mt-8">
          <h2 className="text-lg font-medium">
            Rejected rows
            {record.failed_count > record.error_report.length &&
              ` (showing ${record.error_report.length} of ${record.failed_count})`}
          </h2>
          <ul className="mt-3 divide-y divide-slate-100 rounded-lg border border-slate-200 bg-white text-sm">
            {record.error_report.map((entry) => (
              <li key={entry.row} className="flex flex-wrap gap-x-4 gap-y-1 px-4 py-2">
                <span className="w-16 shrink-0 tabular-nums text-slate-400">Row {entry.row}</span>
                <span className="min-w-0 flex-1 truncate sm:w-64 sm:flex-none">
                  {entry.identifier || '(no email)'}
                </span>
                <span className="w-full text-red-700 sm:w-auto">{entry.errors.join(', ')}</span>
              </li>
            ))}
          </ul>
        </section>
      )}
    </>
  )
}

Show.layout = AppLayout
