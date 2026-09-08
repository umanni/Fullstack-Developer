import { StyledBar, StyledFill } from './ProgressBar.styles'
import { progressVar, type ProgressBarProps } from './ProgressBar.types'

// Accessible progress meter. The fill reads its width from the --progress CSS
// variable (see progressVar) so percentage changes transition smoothly.
export function ProgressBar({ percent, variant, ...rest }: ProgressBarProps) {
  return (
    <StyledBar
      role="progressbar"
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={percent}
      aria-label="Progress"
      {...rest}
    >
      <StyledFill variant={variant} style={progressVar(percent)} />
    </StyledBar>
  )
}
