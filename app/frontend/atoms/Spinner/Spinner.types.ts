import type { ComponentProps } from 'react'

export type SpinnerSize = 'sm' | 'md' | 'lg'

export type SpinnerProps = Omit<ComponentProps<'span'>, 'size'> & {
  size?: SpinnerSize
  /** Accessible label announced while loading (default: "Loading…"). */
  label?: string
}
