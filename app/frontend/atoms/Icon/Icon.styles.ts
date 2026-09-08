import { css, styled, type VariantConfig } from '@/lib/styled'

export const StyledIcon = styled.svg('inline-block shrink-0', {
  variants: css({
    size: {
      sm: 'size-4',
      md: 'size-5',
      lg: 'size-6',
    },
  }),
  defaults: { size: 'md' },
} satisfies VariantConfig)
