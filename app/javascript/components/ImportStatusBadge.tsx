import type { ImportStatus } from '@/types'

const STYLES: Record<ImportStatus, string> = {
  pending: 'bg-slate-100 text-slate-600 ring-slate-200',
  parsing: 'bg-amber-50 text-amber-700 ring-amber-200',
  processing: 'bg-amber-50 text-amber-700 ring-amber-200',
  completed: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
  failed: 'bg-red-50 text-red-700 ring-red-200',
  cancelled: 'bg-slate-100 text-slate-500 ring-slate-200',
}

export default function ImportStatusBadge({ status }: { status: ImportStatus }) {
  return (
    <span
      className={`inline-flex rounded-full px-2 py-0.5 text-xs font-medium capitalize ring-1 ring-inset ${STYLES[status]}`}
    >
      {status}
    </span>
  )
}
