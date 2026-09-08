import type { FormEvent, ReactNode } from 'react'

import { StyledForm } from './Form.styles'

export type FormProps = {
  onSubmit: (event: FormEvent<HTMLFormElement>) => void
  children: ReactNode
}

// Themed <form> shell with consistent vertical rhythm for field stacks.
export function Form({ onSubmit, children }: FormProps) {
  return <StyledForm onSubmit={onSubmit}>{children}</StyledForm>
}
