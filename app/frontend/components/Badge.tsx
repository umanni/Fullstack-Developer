import type { ImportStatus, Role } from '@/types'

import { classNames } from '@/lib/class-names'

const badges: Record<Role | ImportStatus, [string, string]> = {
  admin: ['Admin', 'bg-violet-100 text-violet-700 ring-violet-600/20'],
  user: ['User', 'bg-slate-100 text-slate-700 ring-slate-600/20'],
  pending: ['Queued', 'bg-amber-100 text-amber-800 ring-amber-600/20'],
  processing: ['Processing', 'bg-sky-100 text-sky-700 ring-sky-600/20'],
  completed: [
    'Completed',
    'bg-emerald-100 text-emerald-700 ring-emerald-600/20',
  ],
  completed_with_errors: [
    'Completed with errors',
    'bg-orange-100 text-orange-700 ring-orange-600/20',
  ],
  failed: ['Failed', 'bg-rose-100 text-rose-700 ring-rose-600/20'],
}

export function Badge({ value }: { value: Role | ImportStatus }) {
  const [label, style] = badges[value]

  return (
    <span
      className={classNames(
        'inline-flex rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ring-inset',
        style,
      )}
    >
      {label}
    </span>
  )
}
