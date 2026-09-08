import { css, styled, type VariantConfig } from '@/lib/styled'

export const inputBase = css(
  'block w-full rounded-md border bg-paper px-3 py-2 text-base shadow-sm transition-colors focus:outline-none focus:ring-2 disabled:bg-line-soft disabled:text-ink-mute sm:text-sm',
)

export const inputVariants = css({
  tone: {
    normal:
      'border-line text-ink placeholder:text-ink-mute focus:border-brand focus:ring-brand-ring',
    invalid:
      'border-danger text-ink placeholder:text-ink-mute focus:border-danger focus:ring-danger-ring',
  },
})

export const inputConfig: VariantConfig = {
  variants: inputVariants,
  defaults: { tone: 'normal' },
}

export const StyledInput = styled.input(inputBase, inputConfig)

// Same language for the select dropdown (tone-driven border/ring).
export const StyledSelect = styled.select(inputBase, inputConfig)
