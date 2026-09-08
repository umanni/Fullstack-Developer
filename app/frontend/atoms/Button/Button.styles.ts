import { cn, css, styled, type VariantConfig } from '@/lib/styled'

import type { ButtonSize, ButtonVariant } from './Button.types'

export const buttonBase = css(
  'inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 disabled:pointer-events-none disabled:opacity-50',
)

export const buttonVariants = css({
  variant: {
    primary: 'bg-brand text-white hover:bg-brand-strong focus-visible:ring-brand-ring-strong',
    secondary:
      'bg-paper text-ink border border-line hover:bg-line-soft focus-visible:ring-brand-ring',
    danger: 'bg-danger text-white hover:bg-danger-strong focus-visible:ring-danger-ring-strong',
    ghost: 'bg-transparent text-brand hover:bg-brand-soft focus-visible:ring-brand-ring',
  },
  size: {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-sm',
  },
})

export const buttonConfig: VariantConfig = {
  variants: buttonVariants,
  defaults: { variant: 'primary', size: 'md' },
}

export const StyledButton = styled.button(buttonBase, buttonConfig)

// Shared with ButtonLink (Inertia <Link>) — ButtonLink can't use the styled
// wrapper without giving up SPA navigation, so it composes cn() here (same
// resolution order: base -> variants -> consumer className).
export function buttonClasses(
  options: { variant?: ButtonVariant; size?: ButtonSize } = {},
): string {
  return cn(
    buttonBase,
    buttonVariants.variant[options.variant ?? 'primary'],
    buttonVariants.size[options.size ?? 'md'],
  )
}
