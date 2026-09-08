import { Head, router } from '@inertiajs/react'
import { useEffect, useRef } from 'react'

import { ButtonLink } from '@/components/Button'
import { Icon } from '@/components/Icon'
import { ImportSummary } from '@/components/ImportSummary'
import { PageHeader } from '@/components/PageHeader'
import { useImportProgress } from '@/hooks/useImportProgress'
import { AppLayout } from '@/layouts/AppLayout'
import { formatDate } from '@/lib/formatters'
import { routes } from '@/lib/routes'
import type { UserImport } from '@/types'

const terminalStatuses = new Set([
  'completed',
  'completed_with_errors',
  'failed',
])

export default function ImportShow({
  user_import: initialImport,
}: {
  user_import: UserImport
}) {
  const item = useImportProgress(initialImport)
  const reloaded = useRef(false)

  useEffect(() => {
    if (
      !reloaded.current &&
      terminalStatuses.has(item.status) &&
      !terminalStatuses.has(initialImport.status)
    ) {
      reloaded.current = true
      router.reload({ only: ['user_import'] })
    }
  }, [initialImport.status, item.status])

  return (
    <AppLayout>
      <Head title={`Import ${item.id}`} />
      <PageHeader
        actions={
          <ButtonLink href={routes.adminImports} variant="secondary">
            <Icon className="size-4" name="arrow-left" /> All imports
          </ButtonLink>
        }
        description="Progress is streamed live while the background worker validates and creates users."
        eyebrow="User imports"
        title={`Import #${item.id}`}
      />

      <section
        aria-live="polite"
        className="mt-8 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-7"
      >
        <ImportSummary detailed item={item} />
        {item.failure_message && (
          <div
            className="mt-5 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-800"
            role="alert"
          >
            {item.failure_message}
          </div>
        )}
        {(item.started_at !== null || item.finished_at !== null) && (
          <dl className="mt-6 flex flex-wrap gap-x-8 gap-y-2 border-t border-slate-100 pt-5 text-xs text-slate-500">
            {item.started_at && (
              <div>
                <dt className="inline font-medium">Started: </dt>
                <dd className="inline">{formatDate(item.started_at)}</dd>
              </div>
            )}
            {item.finished_at && (
              <div>
                <dt className="inline font-medium">Finished: </dt>
                <dd className="inline">{formatDate(item.finished_at)}</dd>
              </div>
            )}
          </dl>
        )}
      </section>

      {item.row_errors.length > 0 && (
        <section className="mt-6 overflow-hidden rounded-2xl border border-rose-200 bg-white shadow-sm">
          <div className="border-b border-rose-100 bg-rose-50 px-5 py-4 sm:px-6">
            <h2 className="font-semibold text-rose-900">
              Rows requiring attention
            </h2>
            <p className="mt-1 text-sm text-rose-700">
              Showing up to the first 100 failed rows. Correct these records and
              import them again.
            </p>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-slate-200 text-sm">
              <thead className="bg-slate-50 text-left text-xs font-semibold uppercase tracking-wider text-slate-500">
                <tr>
                  <th className="px-5 py-3">Row</th>
                  <th className="px-5 py-3">Email</th>
                  <th className="px-5 py-3">Error</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {item.row_errors.map((error) => (
                  <tr key={`${error.row_number}-${error.email}`}>
                    <td className="px-5 py-3 font-medium tabular-nums">
                      {error.row_number}
                    </td>
                    <td className="px-5 py-3 text-slate-600">
                      {error.email ?? '—'}
                    </td>
                    <td className="px-5 py-3 text-rose-700">{error.message}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}
    </AppLayout>
  )
}
