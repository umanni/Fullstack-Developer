import type { ReactNode } from 'react'

import { StyledDd, StyledDt, StyledRow } from './DetailRow.styles'

export type DetailRowProps = {
  label: string
  children: ReactNode
}

// Label/value pair for presentational details (dl/div grid row).
export function DetailRow({ label, children }: DetailRowProps) {
  return (
    <StyledRow>
      <StyledDt>{label}</StyledDt>
      <StyledDd>{children}</StyledDd>
    </StyledRow>
  )
}
