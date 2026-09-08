import type { ComponentProps, ElementType } from 'react'

export type HeadingSize = 'sm' | 'md' | 'lg'

export type HeadingProps = Omit<ComponentProps<'h1'>, 'size'> & {
  as?: ElementType
  size?: HeadingSize
}
