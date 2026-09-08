import { StyledSpinner, srOnlyClass } from './Spinner.styles'
import type { SpinnerProps } from './Spinner.types'

// Loading indicator with an accessible role="status" announcement.
export function Spinner({ size, label = 'Loading…', ...rest }: SpinnerProps) {
  return (
    <span role="status" {...rest}>
      <StyledSpinner size={size} aria-hidden="true" />
      <span className={srOnlyClass}>{label}</span>
    </span>
  )
}
