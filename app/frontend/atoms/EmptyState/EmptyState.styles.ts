import { css, styled } from '@/lib/styled'

export const StyledEmptyWrap = styled.div(
  'flex flex-col items-center justify-center gap-2 rounded-md border border-dashed border-line bg-paper px-6 py-10 text-center',
)

export const StyledEmptyIcon = styled.span('text-ink-mute')

export const StyledEmptyTitle = styled.p('text-sm font-semibold text-ink-soft')

export const StyledEmptyDescription = styled.p('max-w-sm text-sm text-ink-mute')

export const StyledEmptyAction = styled.div('mt-2')

// Placeholder text for sr-only when only the icon is shown.
export const emptySrClass = css('sr-only')
