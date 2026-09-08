import { styled } from '@/lib/styled'

export const StyledRow = styled.div(
  'grid grid-cols-1 items-start gap-1.5 border-t border-line-faint py-2 first:border-t-0 sm:grid-cols-[11rem_1fr] sm:gap-4',
)

export const StyledDt = styled.dt('pt-0.5 text-sm font-medium text-ink-mute')

export const StyledDd = styled.dd('flex items-center gap-2 text-sm text-ink')
