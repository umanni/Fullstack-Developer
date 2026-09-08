import type { ComponentProps, ElementType } from 'react'

export type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost'
export type ButtonSize = 'sm' | 'md'

// Native button props (including className/as for polymorphic reuse) without
// the variant machinery, which is re-exported with strict literal unions.
export type ButtonProps = Omit<ComponentProps<'button'>, 'variant' | 'size'> & {
  as?: ElementType
  variant?: ButtonVariant
  size?: ButtonSize
}
