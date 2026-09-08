import { cn, css, styled, type VariantConfig } from '@/lib/styled'

const avatarSizes = css({
  size: {
    sm: 'h-8 w-8',
    md: 'h-10 w-10',
    lg: 'h-20 w-20',
  },
})

const avatarConfig: VariantConfig = {
  variants: avatarSizes,
  defaults: { size: 'md' },
}

export const StyledAvatar = styled.img('rounded-full object-cover ring-1 ring-line', avatarConfig)

export const StyledAvatarFallback = styled.span(
  'inline-flex select-none items-center justify-center rounded-full font-bold uppercase ring-1 ring-line',
  avatarConfig,
)

// Soft-tone backgrounds for letter fallbacks. Each avatar without an image
// gets a random one (see avatarFallbackTone); tones use the theme color pairs.
export const avatarFallbackPalette = [
  { bg: 'bg-brand-soft', text: 'text-brand-strong' },
  { bg: 'bg-ok-soft', text: 'text-ok' },
  { bg: 'bg-warn-soft', text: 'text-warn-strong' },
  { bg: 'bg-danger-soft', text: 'text-danger-strong' },
  { bg: 'bg-line-soft', text: 'text-ink' },
] as const

let lastToneIndex = -1

// Picks a random tone, avoiding an immediate repeat so side-by-side avatars
// (tables, lists) differ from one another.
export function avatarFallbackTone(): string {
  let index = Math.floor(Math.random() * avatarFallbackPalette.length)
  if (index === lastToneIndex) {
    index = (index + 1) % avatarFallbackPalette.length
  }
  lastToneIndex = index
  const { bg, text } = avatarFallbackPalette[index]
  return cn(bg, text)
}
