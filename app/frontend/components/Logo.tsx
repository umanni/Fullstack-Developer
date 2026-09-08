import { Link } from '@inertiajs/react'

import { routes } from '@/lib/routes'

export function Logo() {
  return (
    <Link
      className="inline-flex items-center gap-3 rounded-lg focus-visible:outline-2 focus-visible:outline-brand-500"
      href={routes.home}
    >
      <span className="grid size-10 shrink-0 place-items-center rounded-xl bg-brand-600 text-sm font-black tracking-tight text-white shadow-lg shadow-brand-950/15">
        PH
      </span>
      <span className="text-lg font-bold tracking-tight text-slate-950">
        People<span className="text-brand-600">Hub</span>
      </span>
    </Link>
  )
}
