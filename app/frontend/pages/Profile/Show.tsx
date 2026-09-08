import { Head, router } from '@inertiajs/react'
import { useState } from 'react'

import { Button } from '@/atoms/Button/Button'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { ActionsRow } from '@/molecules/ActionsRow/ActionsRow'
import { Card } from '@/molecules/Card/Card'
import { DetailRow } from '@/molecules/DetailRow/DetailRow'
import { ProfileHeader } from '@/molecules/ProfileHeader/ProfileHeader'
import { ConfirmDialog } from '@/organisms/ConfirmDialog/ConfirmDialog'
import { AuthenticatedLayout } from '@/templates/AuthenticatedLayout/AuthenticatedLayout'
import type { User } from '@/types'

type ProfileShowProps = {
  user: User
  urls: {
    profile_url: string
    admin_url: string
    edit_url: string
    delete_url: string
  }
}

export default function ProfileShow({ user, urls }: ProfileShowProps) {
  const [confirmOpen, setConfirmOpen] = useState(false)

  return (
    <>
      <Head title="My profile" />
      <AuthenticatedLayout profileUrl={urls.profile_url} adminUrl={urls.admin_url}>
        <Card>
          <ProfileHeader
            src={user.avatar_source}
            name={user.full_name}
            email={user.email_address}
          />
          <DetailRow label="Email">{user.email_address}</DetailRow>
          <DetailRow label="Role">{user.role}</DetailRow>
          <ActionsRow>
            <ButtonLink href={urls.edit_url}>Edit profile</ButtonLink>
            <Button
              variant="danger"
              type="button"
              onClick={() => {
                setConfirmOpen(true)
              }}
            >
              Delete account
            </Button>
          </ActionsRow>
        </Card>
      </AuthenticatedLayout>
      <ConfirmDialog
        open={confirmOpen}
        title="Delete account"
        description="Delete your account forever? This cannot be undone."
        confirmLabel="Delete"
        onConfirm={() => router.delete(urls.delete_url)}
        onCancel={() => setConfirmOpen(false)}
      />
    </>
  )
}
