import type { ComponentProps } from 'react'

export type BadgeVariant =
  'neutral' | 'admin' | 'user' | 'pending' | 'processing' | 'completed' | 'failed' | 'danger'

export type BadgeProps = Omit<ComponentProps<'span'>, 'variant'> & {
  variant?: BadgeVariant
}
