import { Head } from '@inertiajs/react'

import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { UserForm } from '@/organisms/UserForm/UserForm'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminPageUrls, User, UserFormData } from '@/types'

type EditUserProps = {
  urls: AdminPageUrls & { submit_url: string; cancel_url: string }
  user?: User
  form?: UserFormData
}

export default function EditUser({ urls, user, form }: EditUserProps) {
  return (
    <>
      <Head title="Admin · Edit user" />
      <AdminLayout urls={urls}>
        <PageHeader title={`Edit ${user?.full_name ?? 'user'}`} />
        <UserForm
          isEdit
          submitLabel="Save changes"
          avatarSource={user?.avatar_source}
          urls={{ submit_url: urls.submit_url, cancel_url: urls.cancel_url }}
          form={form}
        />
      </AdminLayout>
    </>
  )
}
