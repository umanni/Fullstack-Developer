import type { ReactNode } from 'react'

import { StyledActionsRow } from './ActionsRow.styles'

export type ActionsRowProps = {
  children: ReactNode
}

// Horizontal cluster for action buttons (edit/delete, submit/cancel).
export function ActionsRow({ children }: ActionsRowProps) {
  return <StyledActionsRow>{children}</StyledActionsRow>
}
