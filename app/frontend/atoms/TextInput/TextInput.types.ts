import type { ComponentProps } from 'react'

export type InputTone = 'normal' | 'invalid'

// Native input props without the tone machinery (re-exported as strict union).
export type TextInputProps = Omit<ComponentProps<'input'>, 'tone'> & {
  tone?: InputTone
}
