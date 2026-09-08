import type { ComponentProps } from 'react'

export type AlertVariant = 'info' | 'success' | 'warning' | 'danger'

export type AlertProps = Omit<ComponentProps<'div'>, 'variant'> & {
  variant?: AlertVariant
  title?: string
}
