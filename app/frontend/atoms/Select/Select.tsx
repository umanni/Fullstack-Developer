import { forwardRef } from 'react'

import { StyledSelect } from './Select.styles'
import type { SelectProps } from './Select.types'

// Native select with the shared field styling (tone variants available).
export const Select = forwardRef<HTMLSelectElement, SelectProps>(function Select(
  { tone, ...rest },
  ref,
) {
  return <StyledSelect ref={ref} tone={tone} {...rest} />
})
