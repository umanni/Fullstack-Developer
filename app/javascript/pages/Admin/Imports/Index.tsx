import { Head, Link } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'
import ImportStatusBadge from '@/components/ImportStatusBadge'
import LocalTime from '@/components/LocalTime'
import { useLocaleFormat } from '@/hooks/useLocaleFormat'
import type { Import } from '@/types'

/** Props from Admin::ImportsController#index. */
type Props = { imports: Import[] }

const UPLOADED_AT: Intl.DateTimeFormatOptions = { dateStyle: 'medium', timeStyle: 'short' }

export default function Index({ imports }: Props) {
  const format = useLocaleFormat()

  return (
    <>
      <Head title="Imports" />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">Imports</h1>
        <div className="flex items-center gap-4">
          <Link href="/admin/users" className="text-sm text-slate-600 hover:underline">
            Back to users
          </Link>
          <Link
            href="/admin/imports/new"
            className="rounded-md bg-slate-900 px-4 py-2 text-sm text-white hover:bg-slate-700"
          >
            New import
          </Link>
        </div>
      </div>
      <p className="mt-1 text-sm text-slate-500">The 25 most recent uploads.</p>

      <div className="mt-6 overflow-x-auto rounded-lg border border-slate-200 bg-white">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-slate-200 text-xs uppercase text-slate-500">
            <tr>
              <th scope="col" className="px-4 py-3">
                File
              </th>
              <th scope="col" className="px-4 py-3">
                Status
              </th>
              <th scope="col" className="px-4 py-3">
                Rows
              </th>
              <th scope="col" className="px-4 py-3 text-right">
                Created
              </th>
              <th scope="col" className="px-4 py-3 text-right">
                Skipped
              </th>
              <th scope="col" className="px-4 py-3 text-right">
                Failed
              </th>
              <th scope="col" className="px-4 py-3">
                Uploaded
              </th>
            </tr>
          </thead>
          <tbody>
            {imports.map((record) => (
              <tr key={record.id} className="border-b border-slate-100 last:border-0">
                <td className="px-4 py-3">
                  <Link
                    href={`/admin/imports/${record.id}`}
                    className="font-medium hover:underline"
                  >
                    {record.filename}
                  </Link>
                </td>
                <td className="px-4 py-3">
                  <ImportStatusBadge status={record.status} />
                </td>
                <td className="px-4 py-3 tabular-nums text-slate-600">
                  {format.number(record.processed_rows)} of {format.number(record.total_rows)}
                  <span className="text-slate-400"> ({record.progress}%)</span>
                </td>
                <td className="px-4 py-3 text-right tabular-nums">
                  {format.number(record.created_count)}
                </td>
                <td className="px-4 py-3 text-right tabular-nums">
                  {format.number(record.skipped_count)}
                </td>
                <td
                  className={`px-4 py-3 text-right tabular-nums ${record.failed_count > 0 ? 'text-red-600' : ''}`}
                >
                  {format.number(record.failed_count)}
                </td>
                <td className="px-4 py-3 text-slate-600">
                  <LocalTime dateTime={record.created_at} options={UPLOADED_AT} />
                </td>
              </tr>
            ))}
            {imports.length === 0 && (
              <tr>
                <td colSpan={7} className="px-4 py-10 text-center text-slate-500">
                  No imports yet.{' '}
                  <Link href="/admin/imports/new" className="text-slate-900 underline">
                    Upload a spreadsheet
                  </Link>{' '}
                  to add users in bulk.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </>
  )
}

Index.layout = AppLayout
