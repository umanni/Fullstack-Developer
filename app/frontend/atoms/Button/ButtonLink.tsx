import { Link } from '@inertiajs/react'
import type { ComponentProps } from 'react'
import { cn } from '@/lib/styled'

import { buttonClasses } from './Button.styles'
import type { ButtonSize, ButtonVariant } from './Button.types'

type ButtonLinkProps = Omit<ComponentProps<typeof Link>, 'size' | 'variant' | 'className'> & {
  variant?: ButtonVariant
  size?: ButtonSize
  className?: string
}

// Button visuals for SPA navigation: renders an Inertia <Link> (never a plain
// anchor) so clicks go through the shared navigation lifecycle.
export function ButtonLink({ variant, size, className, ...rest }: ButtonLinkProps) {
  return <Link className={cn(buttonClasses({ variant, size }), className)} {...rest} />
}
