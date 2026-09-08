import { styled } from '@/lib/styled'

export const StyledShell = styled.main('grid min-h-screen place-items-center bg-canvas px-4 py-10')

export const StyledMain = styled.div('w-full max-w-md space-y-4')

export const StyledBrand = styled.p(
  'text-center text-xs font-bold uppercase tracking-[0.2em] text-ink-mute',
)

export const StyledCard = styled.section(
  'space-y-5 rounded-lg border border-line bg-paper p-6 shadow-card',
)

export const StyledLinks = styled.nav('flex flex-col items-center gap-2 text-center text-sm')
