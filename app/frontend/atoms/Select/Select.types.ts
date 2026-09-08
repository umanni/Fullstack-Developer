import type { ComponentProps } from 'react'

export type SelectTone = 'normal' | 'invalid'

export type SelectProps = Omit<ComponentProps<'select'>, 'tone'> & {
  tone?: SelectTone
}
