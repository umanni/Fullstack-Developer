import type { ComponentProps } from 'react'

export type IconName =
  | 'alert'
  | 'check'
  | 'download'
  | 'info'
  | 'logout'
  | 'menu'
  | 'plus'
  | 'search'
  | 'upload'
  | 'users'
  | 'x'

export type IconSize = 'sm' | 'md' | 'lg'

export type IconProps = Omit<ComponentProps<'svg'>, 'name' | 'size'> & {
  name: IconName
  size?: IconSize
}
