import { css, styled, type VariantConfig } from '@/lib/styled'

export const StyledBar = styled.span('block h-2 w-full overflow-hidden rounded-full bg-line-soft')

export const StyledFill = styled.span(
  'block h-full w-[var(--progress)] rounded-full transition-[width] duration-300 ease-out',
  {
    variants: css({
      variant: {
        default: 'bg-brand',
        completed: 'bg-ok',
        failed: 'bg-danger',
      },
    }),
    defaults: { variant: 'default' },
  } satisfies VariantConfig,
)
