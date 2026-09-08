import type { ReactNode } from 'react'

import type { IconName } from '@/atoms/Icon/Icon.types'
import { Icon } from '@/atoms/Icon/Icon'

import {
  StyledEmptyAction,
  StyledEmptyDescription,
  StyledEmptyIcon,
  StyledEmptyTitle,
  StyledEmptyWrap,
} from './EmptyState.styles'

export type EmptyStateProps = {
  icon?: IconName
  title: string
  description?: string
  action?: ReactNode
}

// Friendly "nothing here yet" panel that hosts an optional action (atom/molecule).
export function EmptyState({ icon, title, description, action }: EmptyStateProps) {
  return (
    <StyledEmptyWrap>
      {icon ? (
        <StyledEmptyIcon>
          <Icon name={icon} size="lg" aria-hidden="true" />
        </StyledEmptyIcon>
      ) : null}
      <StyledEmptyTitle>{title}</StyledEmptyTitle>
      {description ? <StyledEmptyDescription>{description}</StyledEmptyDescription> : null}
      {action ? <StyledEmptyAction>{action}</StyledEmptyAction> : null}
    </StyledEmptyWrap>
  )
}
