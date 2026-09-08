import { Link } from '@inertiajs/react'

import { Icon } from '@/components/Icon'
import type { Pagination as PaginationData } from '@/types'

export function Pagination({
  pagination,
  hrefFor,
}: {
  pagination: PaginationData
  hrefFor: (page: number) => string
}) {
  if (pagination.pages <= 1) return null

  return (
    <nav
      aria-label="Pagination"
      className="flex items-center justify-between border-t border-slate-200 px-4 py-4 sm:px-6"
    >
      <p className="hidden text-sm text-slate-500 sm:block">
        Page{' '}
        <span className="font-semibold text-slate-700">{pagination.page}</span>{' '}
        of {pagination.pages}
      </p>
      <div className="flex w-full gap-3 sm:w-auto">
        {pagination.previous ? (
          <Link
            className="inline-flex min-h-10 flex-1 items-center justify-center gap-1 rounded-xl border border-slate-300 bg-white px-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 sm:flex-none"
            href={hrefFor(pagination.previous)}
            preserveScroll
          >
            <Icon className="size-4" name="chevron-left" /> Previous
          </Link>
        ) : (
          <span />
        )}
        {pagination.next && (
          <Link
            className="inline-flex min-h-10 flex-1 items-center justify-center gap-1 rounded-xl border border-slate-300 bg-white px-3 text-sm font-semibold text-slate-700 hover:bg-slate-50 sm:flex-none"
            href={hrefFor(pagination.next)}
            preserveScroll
          >
            Next <Icon className="size-4" name="chevron-right" />
          </Link>
        )}
      </div>
    </nav>
  )
}
