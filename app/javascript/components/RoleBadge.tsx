import type { UserRole } from '@/types'

const STYLES: Record<UserRole, string> = {
  admin: 'bg-indigo-50 text-indigo-700 ring-indigo-200',
  member: 'bg-slate-100 text-slate-600 ring-slate-200',
}

export default function RoleBadge({ role }: { role: UserRole }) {
  return (
    <span
      className={`inline-flex rounded-full px-2 py-0.5 text-xs font-medium capitalize ring-1 ring-inset ${STYLES[role]}`}
    >
      {role}
    </span>
  )
}
