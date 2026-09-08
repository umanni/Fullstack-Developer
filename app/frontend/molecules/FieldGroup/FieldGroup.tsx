import type { ReactNode } from 'react'

import { StyledFieldGroup } from './FieldGroup.styles'

export type FieldGroupProps = {
  children: ReactNode
}

// Inline cluster for a labelled control plus a companion action (e.g. Go).
export function FieldGroup({ children }: FieldGroupProps) {
  return <StyledFieldGroup>{children}</StyledFieldGroup>
}
