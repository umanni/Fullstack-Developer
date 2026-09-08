import type { ComponentProps } from 'react'

export type AvatarSize = 'sm' | 'md' | 'lg'

export type AvatarProps = {
  src: string | null | undefined
  alt?: string
  size?: AvatarSize
} & Omit<ComponentProps<'img'> & ComponentProps<'span'>, 'src' | 'alt' | 'size'>
