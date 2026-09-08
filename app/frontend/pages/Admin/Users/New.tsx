import { Head } from '@inertiajs/react'

import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { UserForm } from '@/organisms/UserForm/UserForm'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminPageUrls, UserFormData } from '@/types'

type NewUserProps = {
  urls: AdminPageUrls & { submit_url: string; cancel_url: string }
  form?: UserFormData
}

export default function NewUser({ urls, form }: NewUserProps) {
  return (
    <>
      <Head title="Admin · New user" />
      <AdminLayout urls={urls}>
        <PageHeader title="New user" />
        <UserForm
          isEdit={false}
          submitLabel="Create user"
          urls={{ submit_url: urls.submit_url, cancel_url: urls.cancel_url }}
          form={form}
        />
      </AdminLayout>
    </>
  )
}
