import type { ButtonProps } from './Button.types'
import { StyledButton } from './Button.styles'

// Primary interaction atom. Variant + size resolved by the styled wrapper;
// consumer className is merged last (Tailwind-aware, see lib/styled).
export function Button({ variant, size, ...rest }: ButtonProps) {
  return <StyledButton variant={variant} size={size} {...rest} />
}
