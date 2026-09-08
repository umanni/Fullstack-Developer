import type { ReactNode } from 'react'

import { Icon, type IconName } from '@/components/Icon'

export function EmptyState({
  icon,
  title,
  description,
  action,
}: {
  icon: IconName
  title: string
  description: string
  action?: ReactNode
}) {
  return (
    <div className="flex flex-col items-center rounded-2xl border border-dashed border-slate-300 bg-white px-6 py-14 text-center">
      <span className="mb-4 grid size-12 place-items-center rounded-2xl bg-brand-50 text-brand-700">
        <Icon name={icon} />
      </span>
      <h2 className="font-semibold text-slate-950">{title}</h2>
      <p className="mt-1 max-w-md text-sm leading-6 text-slate-500">
        {description}
      </p>
      {action && <div className="mt-5">{action}</div>}
    </div>
  )
}
