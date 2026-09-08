import { Label } from '@/atoms/Label/Label'

import { StyledError, StyledField, StyledHint } from './Field.styles'
import type { FieldProps } from './Field.types'

// Label + control (atom) + error/hint wiring. Error takes precedence over hint.
export function Field({ label, htmlFor, hint, error, children }: FieldProps) {
  return (
    <StyledField>
      <Label htmlFor={htmlFor}>{label}</Label>
      {children}
      {error ? (
        <StyledError role="alert">{error}</StyledError>
      ) : hint ? (
        <StyledHint>{hint}</StyledHint>
      ) : null}
    </StyledField>
  )
}
