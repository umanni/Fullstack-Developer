import { router } from '@inertiajs/react'
import { useState } from 'react'

import { Avatar } from '@/atoms/Avatar/Avatar'
import { Button } from '@/atoms/Button/Button'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { EmptyState } from '@/atoms/EmptyState/EmptyState'
import { RoleBadge } from '@/molecules/RoleBadge/RoleBadge'
import type { AdminUser } from '@/types'

import { ConfirmDialog } from '@/organisms/ConfirmDialog/ConfirmDialog'
import {
  StyledActions,
  StyledActionsWrap,
  StyledCell,
  StyledHead,
  StyledHeadCell,
  StyledRow,
  StyledScroll,
  StyledTable,
  StyledUserCell,
} from './UserTable.styles'

export type UserTableProps = {
  users: AdminUser[]
}

// Admin user listing with SPA actions. Destructive delete routes through the
// ConfirmDialog (focus-trapped) instead of a browser confirm.
export function UserTable({ users }: UserTableProps) {
  const [pendingDelete, setPendingDelete] = useState<AdminUser | null>(null)

  function handleToggle(user: AdminUser) {
    router.patch(user.toggle_url)
  }

  function confirmDelete() {
    if (!pendingDelete) return
    router.delete(pendingDelete.delete_url)
    setPendingDelete(null)
  }

  if (users.length === 0) {
    return <EmptyState icon="users" title="No users found" description="Try a different search." />
  }

  return (
    <>
      <StyledScroll>
        <StyledTable>
          <StyledHead>
            <tr>
              <StyledHeadCell>User</StyledHeadCell>
              <StyledHeadCell>Email</StyledHeadCell>
              <StyledHeadCell>Role</StyledHeadCell>
              <StyledHeadCell>Actions</StyledHeadCell>
            </tr>
          </StyledHead>
          <tbody>
            {users.map((user) => (
              <StyledRow key={user.id}>
                <StyledCell>
                  <StyledUserCell>
                    <Avatar src={user.avatar_source} alt={user.full_name} size="sm" />
                    {user.full_name}
                  </StyledUserCell>
                </StyledCell>
                <StyledCell>{user.email_address}</StyledCell>
                <StyledCell>
                  <RoleBadge role={user.role} />
                </StyledCell>
                <StyledActions>
                  <StyledActionsWrap>
                    <ButtonLink href={user.edit_url} variant="ghost" size="sm">
                      Edit
                    </ButtonLink>
                    <Button
                      variant="secondary"
                      size="sm"
                      type="button"
                      onClick={() => handleToggle(user)}
                    >
                      {user.role === 'admin' ? 'Make user' : 'Make admin'}
                    </Button>
                    <Button
                      variant="danger"
                      size="sm"
                      type="button"
                      onClick={() => setPendingDelete(user)}
                    >
                      Delete
                    </Button>
                  </StyledActionsWrap>
                </StyledActions>
              </StyledRow>
            ))}
          </tbody>
        </StyledTable>
      </StyledScroll>
      <ConfirmDialog
        open={pendingDelete != null}
        title="Delete user"
        description={`Delete ${pendingDelete?.full_name ?? ''}? This cannot be undone.`}
        onConfirm={confirmDelete}
        onCancel={() => setPendingDelete(null)}
      />
    </>
  )
}
