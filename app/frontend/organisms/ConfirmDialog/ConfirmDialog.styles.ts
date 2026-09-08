import { styled } from '@/lib/styled'

export const StyledBackdrop = styled.div('fixed inset-0 z-50 grid place-items-center bg-scrim p-4')

export const StyledPanel = styled.div(
  'w-full max-w-sm max-h-[85vh] overflow-y-auto rounded-lg border border-line bg-paper p-5 shadow-pop',
)

export const StyledDescription = styled.p('mt-2 text-sm text-ink-mute')

export const StyledActions = styled.div('mt-5 flex flex-wrap justify-end gap-2')
