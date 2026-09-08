import { styled } from '@/lib/styled'

// Scroll container so wide tables degrade to horizontal scroll on phones
// instead of crushing the columns. Mobile Safari gets momentum scrolling.
export const StyledScroll = styled.div(
  'overflow-x-auto rounded-md border border-line shadow-card [-webkit-overflow-scrolling:touch]',
)

export const StyledTable = styled.table('w-full min-w-[42rem] border-collapse bg-paper text-sm')

export const StyledHead = styled.thead('bg-line-soft-strong')

export const StyledRow = styled.tr(
  'border-b border-line transition-colors last:border-b-0 hover:bg-line-soft-tint',
)

export const StyledHeadCell = styled.th(
  'px-4 py-2 text-left text-xs font-semibold uppercase tracking-wide text-ink-mute',
)

export const StyledCell = styled.td('px-4 py-3 align-middle')

export const StyledUserCell = styled.span('flex items-center gap-2 font-medium text-ink')

export const StyledActions = styled.td('px-4 py-3 whitespace-nowrap')

export const StyledActionsWrap = styled.span('flex items-center justify-end gap-2')
