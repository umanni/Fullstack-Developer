import { css, styled, type VariantConfig } from '@/lib/styled'

export const StyledAlert = styled.div(
  'flex items-start gap-2 rounded-md border px-4 py-3 text-sm',
  {
    variants: css({
      variant: {
        info: 'border-brand-faint bg-brand-soft text-ink',
        success: 'border-ok-faint bg-ok-soft text-ink',
        warning: 'border-warn-faint bg-warn-soft text-ink',
        danger: 'border-danger-faint bg-danger-soft text-danger-strong',
      },
    }),
    defaults: { variant: 'info' },
  } satisfies VariantConfig,
)

export const AlertContent = styled.div('min-w-0 flex-1')

export const AlertTitle = styled.p('font-medium')

export const AlertBody = styled.p('mt-0.5')
