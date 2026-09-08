import type { CSSProperties, ComponentProps } from 'react'

export type ProgressVariant = 'default' | 'completed' | 'failed'

export type ProgressBarProps = Omit<ComponentProps<'span'>, 'variant'> & {
  percent: number
  variant?: ProgressVariant
}

// The fill width is a dynamic CSS variable — the single documented inline
// style (cssVar) exception allowed by the phase spec.
export function progressVar(percent: number): CSSProperties {
  return { ['--progress' as string]: `${Math.min(100, Math.max(0, percent))}%` } as CSSProperties
}
