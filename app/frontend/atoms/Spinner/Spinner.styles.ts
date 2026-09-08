import { css, styled, type VariantConfig } from '@/lib/styled'

export const StyledSpinner = styled.span(
  'inline-block animate-spin rounded-full border-2 border-current border-r-transparent',
  {
    variants: css({
      size: {
        sm: 'size-3',
        md: 'size-4',
        lg: 'size-6',
      },
    }),
    defaults: { size: 'md' },
  } satisfies VariantConfig,
)

// Screen-reader-only companion (no utility classes allowed in JSX).
export const srOnlyClass = css('sr-only')
