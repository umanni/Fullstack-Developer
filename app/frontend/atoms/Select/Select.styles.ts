import { css, styled, type VariantConfig } from '@/lib/styled'

export const selectBase = css(
  'block w-full rounded-md border bg-paper px-3 py-2 text-base shadow-sm transition-colors focus:outline-none focus:ring-2 disabled:bg-line-soft disabled:text-ink-mute sm:text-sm',
)

export const selectVariants = css({
  tone: {
    normal: 'border-line text-ink focus:border-brand focus:ring-brand-ring',
    invalid: 'border-danger text-ink focus:border-danger focus:ring-danger-ring',
  },
})

export const selectConfig: VariantConfig = {
  variants: selectVariants,
  defaults: { tone: 'normal' },
}

export const StyledSelect = styled.select(selectBase, selectConfig)
