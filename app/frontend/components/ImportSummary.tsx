import { Badge } from '@/components/Badge'
import { ProgressBar } from '@/components/ProgressBar'
import { formatDate, pluralize } from '@/lib/formatters'
import type { UserImport } from '@/types'

export function ImportSummary({
  item,
  detailed = false,
}: {
  item: UserImport
  detailed?: boolean
}) {
  return (
    <div>
      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="min-w-0">
          <p className="truncate font-semibold text-slate-950">
            {item.file_name ?? 'Spreadsheet'}
          </p>
          <p className="mt-1 text-xs text-slate-500">
            Uploaded by {item.uploaded_by} · {formatDate(item.created_at)}
          </p>
        </div>
        <Badge value={item.status} />
      </div>

      <div className="mt-5">
        <ProgressBar
          label={`${pluralize(item.processed_rows, 'row')} processed`}
          value={item.progress_percentage}
        />
      </div>

      {detailed && (
        <dl className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4">
          {[
            ['Total', item.total_rows],
            ['Processed', item.processed_rows],
            ['Created', item.successful_rows],
            ['Failed', item.failed_rows],
          ].map(([label, value]) => (
            <div className="rounded-xl bg-slate-50 p-3" key={label}>
              <dt className="text-xs font-medium text-slate-500">{label}</dt>
              <dd className="mt-1 text-xl font-bold text-slate-950 tabular-nums">
                {value}
              </dd>
            </div>
          ))}
        </dl>
      )}
    </div>
  )
}
