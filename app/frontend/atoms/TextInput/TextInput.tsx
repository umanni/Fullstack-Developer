import { forwardRef } from 'react'

import { StyledInput } from './TextInput.styles'
import type { TextInputProps } from './TextInput.types'

export const TextInput = forwardRef<HTMLInputElement, TextInputProps>(function TextInput(
  { tone, ...rest },
  ref,
) {
  return (
    <StyledInput ref={ref} tone={tone} aria-invalid={tone === 'invalid' || undefined} {...rest} />
  )
})
