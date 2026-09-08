import { StyledBadge } from './Badge.styles'
import type { BadgeProps } from './Badge.types'

// Tiny labelled status chip. Variant resolved by the styled wrapper.
export function Badge({ variant, ...rest }: BadgeProps) {
  return <StyledBadge variant={variant} {...rest} />
}
