import { Head, router, useForm } from '@inertiajs/react'

import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { SearchBar } from '@/molecules/SearchBar/SearchBar'
import { Pagination } from '@/organisms/Pagination/Pagination'
import { UserTable } from '@/organisms/UserTable/UserTable'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminPageUrls, AdminUser, Pagination as PaginationData } from '@/types'

type UsersIndexProps = {
  users: AdminUser[]
  pagination: PaginationData
  filters: { search: string }
  urls: AdminPageUrls & { new_url: string }
}

export default function UsersIndex({ users, pagination, filters, urls }: UsersIndexProps) {
  const { data, setData } = useForm({ search: filters.search })

  function reload(search: string, page: number) {
    router.reload({
      data: { search, page: String(page) },
      only: ['users', 'pagination', 'filters'],
    })
  }

  function handleSearch() {
    reload(data.search, 1)
  }

  return (
    <>
      <Head title="Admin · Users" />
      <AdminLayout urls={urls}>
        <PageHeader
          title="Users"
          action={
            <ButtonLink variant="secondary" href={urls.new_url}>
              New user
            </ButtonLink>
          }
        />
        <SearchBar
          value={data.search}
          onChange={(value) => setData('search', value)}
          onSubmit={handleSearch}
          placeholder="Search by name or email"
        />
        <UserTable users={users} />
        <Pagination
          page={pagination.page}
          pages={pagination.pages}
          count={pagination.count}
          countLabel="users"
          onPrevious={() => reload(filters.search, pagination.prev ?? 1)}
          onNext={() => reload(filters.search, pagination.next ?? 1)}
        />
      </AdminLayout>
    </>
  )
}
