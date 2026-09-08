import { css, styled, type VariantConfig } from '@/lib/styled'

export const badgeBase = css(
  'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium',
)

export const badgeVariants = css({
  variant: {
    neutral: 'bg-line-soft text-ink-mute',
    admin: 'bg-brand-soft text-brand-strong',
    user: 'bg-line-soft text-ink-mute',
    pending: 'bg-warn-soft text-warn',
    processing: 'bg-brand-soft text-brand-strong',
    completed: 'bg-ok-soft text-ok',
    failed: 'bg-danger-soft text-danger-strong',
    danger: 'bg-danger-soft text-danger-strong',
  },
})

export const badgeConfig: VariantConfig = {
  variants: badgeVariants,
  defaults: { variant: 'neutral' },
}

export const StyledBadge = styled.span(badgeBase, badgeConfig)
