import type { ReactNode } from 'react'

import { StyledFormActions } from './Form.styles'

// Submit + cancel cluster at the end of a form.
export function FormActions({ children }: { children: ReactNode }) {
  return <StyledFormActions>{children}</StyledFormActions>
}
