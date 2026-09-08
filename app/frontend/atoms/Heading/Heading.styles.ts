import { css, styled, type VariantConfig } from '@/lib/styled'

export const headingTags = css({
  sm: 'h3',
  md: 'h2',
  lg: 'h1',
} as const)

export const StyledHeading = styled.h1('m-0 font-bold tracking-tight text-ink', {
  variants: css({
    size: {
      sm: 'text-base font-semibold',
      md: 'text-xl',
      lg: 'text-2xl',
    },
  }),
  defaults: { size: 'lg' },
} satisfies VariantConfig)
