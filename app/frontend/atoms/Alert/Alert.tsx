import { Icon } from '@/atoms/Icon/Icon'
import type { IconName } from '@/atoms/Icon/Icon.types'

import { AlertContent, AlertBody, AlertTitle, StyledAlert } from './Alert.styles'
import type { AlertProps } from './Alert.types'

const ICON: Record<NonNullable<AlertProps['variant']>, IconName> = {
  info: 'info',
  success: 'check',
  warning: 'alert',
  danger: 'alert',
}

// User-facing feedback box. role="alert" for errors, "status" otherwise.
export function Alert({ variant = 'info', title, children, ...rest }: AlertProps) {
  return (
    <StyledAlert variant={variant} role={variant === 'danger' ? 'alert' : 'status'} {...rest}>
      <Icon name={ICON[variant]} size="sm" />
      <AlertContent>
        {title ? <AlertTitle>{title}</AlertTitle> : null}
        {children ? <AlertBody>{children}</AlertBody> : null}
      </AlertContent>
    </StyledAlert>
  )
}
