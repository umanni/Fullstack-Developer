import { Head, usePage } from '@inertiajs/react'

import { TextLink } from '@/atoms/TextLink/TextLink'
import { DashboardStats } from '@/organisms/DashboardStats/DashboardStats'
import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminPageUrls, UsersOverview } from '@/types'

type AdminDashboardProps = {
  overview?: UsersOverview
  urls?: AdminPageUrls
}

export default function AdminDashboard({ overview, urls }: AdminDashboardProps) {
  const user = usePage().props.auth.user

  const navUrls: AdminPageUrls = {
    dashboard_url: '/admin',
    users_url: urls?.users_url ?? '/admin/users',
    imports_url: urls?.imports_url ?? '/admin/user_imports',
  }

  return (
    <>
      <Head title="Admin dashboard" />
      <AdminLayout urls={navUrls}>
        <PageHeader title="Admin dashboard" description={`Signed in as ${user?.full_name}.`} />
        <DashboardStats overview={overview} />
        <div>
          <TextLink href={urls?.users_url ?? '/admin/users'}>Manage users</TextLink>
        </div>
      </AdminLayout>
    </>
  )
}
