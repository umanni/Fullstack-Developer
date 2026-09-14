import { Head, Link, router, usePage } from '@inertiajs/react'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import AppLayout from '@/layouts/AppLayout'
import Avatar from '@/components/Avatar'
import LocalTime from '@/components/LocalTime'
import RoleBadge from '@/components/RoleBadge'
import type { Filters, SearchParams, SortKey, User, UserRole } from '@/types'

const ONLY = ['users', 'filters'] as const

const COLUMNS: { key: SortKey; label: string }[] = [
  { key: 'full_name', label: 'User' },
  { key: 'role', label: 'Role' },
  { key: 'created_at', label: 'Joined' },
]

const JOINED_AT: Intl.DateTimeFormatOptions = { dateStyle: 'medium' }

/** Drops the read-only half of `filters` so pagination links carry only real query params. */
function searchParams(filters: Filters): SearchParams {
  const { query, sort, direction, role, page } = filters
  return { query, sort, direction, role, page }
}

export default function Index() {
  const { users, filters } = usePage<{ users: User[]; filters: Filters }>().props
  const { auth } = usePage().props

  const [query, setQuery] = useState(filters.query)
  const params = useMemo(() => searchParams(filters), [filters])
  const isFirstRender = useRef(true)

  const visit = useCallback(
    (overrides: Partial<SearchParams>) => {
      router.get(
        '/admin/users',
        { ...params, page: 1, ...overrides },
        {
          only: [...ONLY],
          preserveState: true,
          preserveScroll: true,
          replace: true,
        },
      )
    },
    [params],
  )

  // Debounce the search box so typing doesn't fire a request per keystroke.
  useEffect(() => {
    if (isFirstRender.current) {
      isFirstRender.current = false
      return
    }
    if (query === filters.query) return

    const timer = setTimeout(() => visit({ query }), 300)
    return () => clearTimeout(timer)
  }, [query, filters.query, visit])

  const sortBy = useCallback(
    (key: SortKey) => {
      const direction = filters.sort === key && filters.direction === 'asc' ? 'desc' : 'asc'
      visit({ sort: key, direction })
    },
    [filters.sort, filters.direction, visit],
  )

  const toggleRole = useCallback((user: User) => {
    router.patch(`/admin/users/${user.id}/role`, {}, { preserveScroll: true })
  }, [])

  const destroy = useCallback((user: User) => {
    if (!window.confirm(`Delete ${user.full_name}? This cannot be undone.`)) return
    router.delete(`/admin/users/${user.id}`, { preserveScroll: true })
  }, [])

  const ariaSort = (key: SortKey) => {
    if (filters.sort !== key) return undefined
    return filters.direction === 'asc' ? ('ascending' as const) : ('descending' as const)
  }

  return (
    <>
      <Head title="Users" />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">
          Users <span className="text-slate-400">({filters.total})</span>
        </h1>
        <div className="flex items-center gap-2">
          <Link
            href="/admin/imports/new"
            className="rounded-md border border-slate-300 bg-white px-4 py-2 text-sm text-slate-700 hover:bg-slate-50"
          >
            Import users
          </Link>
          <Link
            href="/admin/users/new"
            className="rounded-md bg-slate-900 px-4 py-2 text-sm text-white hover:bg-slate-700"
          >
            New user
          </Link>
        </div>
      </div>

      <div className="mt-4 flex flex-wrap gap-2">
        <input
          type="search"
          value={query}
          onChange={(event) => setQuery(event.target.value)}
          placeholder="Search by name"
          aria-label="Search users by name"
          className="w-full rounded-md border border-slate-300 px-3 py-2 text-base sm:w-64 sm:text-sm"
        />
        <select
          value={filters.role ?? ''}
          onChange={(event) => visit({ role: (event.target.value || null) as UserRole | null })}
          aria-label="Filter by role"
          className="rounded-md border border-slate-300 py-2 pr-9 pl-3 text-base sm:text-sm"
        >
          <option value="">All roles</option>
          <option value="admin">Admin</option>
          <option value="member">Member</option>
        </select>
      </div>

      <div className="mt-6 overflow-x-auto rounded-lg border border-slate-200 bg-white">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-slate-200 text-xs uppercase text-slate-500">
            <tr>
              {COLUMNS.map(({ key, label }) => (
                <th key={key} scope="col" aria-sort={ariaSort(key)} className="px-4 py-3">
                  <button
                    type="button"
                    onClick={() => sortBy(key)}
                    className="inline-flex items-center gap-1 uppercase hover:text-slate-900"
                  >
                    {label}
                    <span aria-hidden className="text-slate-400">
                      {filters.sort === key ? (filters.direction === 'asc' ? '↑' : '↓') : '↕'}
                    </span>
                  </button>
                </th>
              ))}
              <th scope="col" className="px-4 py-3">
                Email
              </th>
              <th scope="col" className="px-4 py-3 text-right">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id} className="border-b border-slate-100 last:border-0">
                <td className="px-4 py-3">
                  <div className="flex items-center gap-3">
                    <Avatar user={user} />
                    <Link href={`/admin/users/${user.id}`} className="font-medium hover:underline">
                      {user.full_name}
                    </Link>
                  </div>
                </td>
                <td className="px-4 py-3">
                  <RoleBadge role={user.role} />
                </td>
                <td className="px-4 py-3 text-slate-600">
                  <LocalTime dateTime={user.created_at} options={JOINED_AT} />
                </td>
                <td className="px-4 py-3 text-slate-600">{user.email_address}</td>
                <td className="px-4 py-3">
                  <div className="flex justify-end gap-3">
                    {user.id !== auth.user?.id && (
                      <button
                        type="button"
                        onClick={() => toggleRole(user)}
                        className="text-slate-600 hover:underline"
                      >
                        Make {user.admin ? 'member' : 'admin'}
                      </button>
                    )}
                    <Link
                      href={`/admin/users/${user.id}/edit`}
                      className="text-slate-600 hover:underline"
                    >
                      Edit
                    </Link>
                    <button
                      type="button"
                      onClick={() => destroy(user)}
                      className="text-red-600 hover:underline"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            ))}
            {users.length === 0 && (
              <tr>
                <td colSpan={5} className="px-4 py-10 text-center text-slate-500">
                  No users match those filters.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {filters.total_pages > 1 && (
        <nav className="mt-4 flex justify-center gap-2" aria-label="Pagination">
          {Array.from({ length: filters.total_pages }, (_, index) => index + 1).map((page) => (
            <Link
              key={page}
              href="/admin/users"
              data={{ ...params, page }}
              only={[...ONLY]}
              preserveState
              preserveScroll
              aria-current={page === filters.page ? 'page' : undefined}
              aria-label={`Page ${page}`}
              className={`rounded px-3 py-1 text-sm ${
                page === filters.page
                  ? 'bg-slate-900 text-white'
                  : 'border border-slate-300 bg-white'
              }`}
            >
              {page}
            </Link>
          ))}
        </nav>
      )}
    </>
  )
}

Index.layout = AppLayout
