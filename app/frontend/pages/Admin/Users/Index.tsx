import { Head, router, usePage } from '@inertiajs/react'
import { useState, type FormEvent } from 'react'

import { Avatar } from '@/components/Avatar'
import { Badge } from '@/components/Badge'
import { Button, ButtonLink } from '@/components/Button'
import { EmptyState } from '@/components/EmptyState'
import { Icon } from '@/components/Icon'
import { PageHeader } from '@/components/PageHeader'
import { Pagination } from '@/components/Pagination'
import { AppLayout } from '@/layouts/AppLayout'
import { formatDate, pluralize } from '@/lib/formatters'
import { routes } from '@/lib/routes'
import type { Pagination as PaginationData, User } from '@/types'

type Filters = { query: string; role: string }

export default function UsersIndex({
  users,
  pagination,
  filters,
}: {
  users: User[]
  pagination: PaginationData
  filters: Filters
}) {
  const currentUser = usePage().props.auth.user
  const [query, setQuery] = useState(filters.query)
  const [role, setRole] = useState(filters.role)

  const search = (event: FormEvent) => {
    event.preventDefault()
    router.get(
      routes.adminUsers,
      { query, role },
      { preserveState: true, replace: true },
    )
  }

  const filteredUrl = (page: number) => {
    const params = new URLSearchParams({ page: page.toString() })
    if (filters.query) params.set('query', filters.query)
    if (filters.role) params.set('role', filters.role)
    return `${routes.adminUsers}?${params.toString()}`
  }

  const toggleRole = (user: User) => {
    const nextRole = user.role === 'admin' ? 'standard user' : 'administrator'
    if (window.confirm(`Change ${user.full_name}'s role to ${nextRole}?`)) {
      router.patch(
        routes.toggleAdminUserRole(user.id),
        {},
        { preserveScroll: true },
      )
    }
  }

  const removeUser = (user: User) => {
    if (
      window.confirm(`Delete ${user.full_name}? This action cannot be undone.`)
    ) {
      router.delete(routes.adminUser(user.id), { preserveScroll: true })
    }
  }

  return (
    <AppLayout>
      <Head title="Users" />
      <PageHeader
        actions={
          <>
            <ButtonLink href={routes.newAdminImport} variant="secondary">
              <Icon className="size-4" name="upload" /> Import
            </ButtonLink>
            <ButtonLink href={routes.newAdminUser}>
              <Icon className="size-4" name="plus" /> Add user
            </ButtonLink>
          </>
        }
        description={`${pluralize(pagination.count, 'person')} in the workspace. Search, edit access and manage accounts.`}
        eyebrow="Administration"
        title="Users"
      />

      <form
        className="mt-8 flex flex-col gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm sm:flex-row"
        onSubmit={search}
      >
        <label className="relative flex-1">
          <span className="sr-only">Search users</span>
          <Icon
            className="pointer-events-none absolute left-3.5 top-3 size-5 text-slate-400"
            name="search"
          />
          <input
            className="min-h-11 w-full rounded-xl border-slate-300 pl-11 text-sm shadow-sm focus:border-brand-500 focus:ring-brand-500"
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search by name or email…"
            type="search"
            value={query}
          />
        </label>
        <label>
          <span className="sr-only">Filter by role</span>
          <select
            className="min-h-11 w-full rounded-xl border-slate-300 text-sm shadow-sm focus:border-brand-500 focus:ring-brand-500 sm:w-44"
            onChange={(event) => setRole(event.target.value)}
            value={role}
          >
            <option value="">All roles</option>
            <option value="admin">Administrators</option>
            <option value="user">Standard users</option>
          </select>
        </label>
        <Button type="submit">Apply filters</Button>
        {(filters.query || filters.role) && (
          <ButtonLink href={routes.adminUsers} variant="ghost">
            Clear
          </ButtonLink>
        )}
      </form>

      <section className="mt-5 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
        {users.length === 0 ? (
          <div className="p-5 sm:p-8">
            <EmptyState
              action={
                <ButtonLink href={routes.newAdminUser}>
                  <Icon className="size-4" name="plus" /> Add user
                </ButtonLink>
              }
              description="Try adjusting your search or add the first person to this workspace."
              icon="users"
              title="No users found"
            />
          </div>
        ) : (
          <>
            <ul className="grid gap-3 p-3 sm:grid-cols-2 sm:p-4">
              {users.map((user) => (
                <li
                  className="rounded-xl border border-slate-200 p-4 transition-shadow hover:shadow-sm"
                  key={user.id}
                >
                  <div className="flex items-start gap-3">
                    <Avatar
                      name={user.full_name}
                      size="sm"
                      src={user.avatar_url}
                    />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-start justify-between gap-2">
                        <p className="truncate text-sm font-semibold text-slate-900">
                          {user.full_name}
                        </p>
                        <Badge value={user.role} />
                      </div>
                      <p className="truncate text-xs text-slate-500">
                        {user.email}
                      </p>
                      <p className="mt-2 text-xs text-slate-500">
                        Joined{' '}
                        {formatDate(user.created_at, {
                          dateStyle: 'medium',
                          timeStyle: undefined,
                        })}
                      </p>
                    </div>
                  </div>
                  <div className="mt-4 flex gap-2 border-t border-slate-100 pt-3">
                    <ButtonLink
                      className="flex-1"
                      href={routes.editAdminUser(user.id)}
                      size="sm"
                      variant="ghost"
                    >
                      <Icon className="size-4" name="edit" /> Edit
                    </ButtonLink>
                    <Button
                      disabled={currentUser?.id === user.id}
                      onClick={() => toggleRole(user)}
                      size="sm"
                      variant="secondary"
                    >
                      <Icon className="size-4" name="shield" /> Role
                    </Button>
                    <Button
                      aria-label={`Delete ${user.full_name}`}
                      disabled={currentUser?.id === user.id}
                      onClick={() => removeUser(user)}
                      size="sm"
                      variant="ghost"
                    >
                      <Icon className="size-4 text-rose-600" name="trash" />
                    </Button>
                  </div>
                </li>
              ))}
            </ul>
            <Pagination hrefFor={filteredUrl} pagination={pagination} />
          </>
        )}
      </section>
    </AppLayout>
  )
}
