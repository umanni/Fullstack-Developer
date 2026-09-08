import { useState } from 'react'

import { avatarFallbackTone, StyledAvatar, StyledAvatarFallback } from './Avatar.styles'
import type { AvatarProps } from './Avatar.types'

// Renders the image when available, otherwise a bold single-letter fallback
// (no broken img bubbles in tables). The letter is the first character of the
// name, uppercased; the background tone is randomized per avatar instance.
export function Avatar({ src, alt = '', size = 'md', ...rest }: AvatarProps) {
  const [fallbackTone] = useState(avatarFallbackTone)

  if (src) {
    return <StyledAvatar src={src} alt={alt} size={size} {...rest} />
  }

  return (
    <StyledAvatarFallback size={size} role="img" aria-label={alt} className={fallbackTone}>
      {alt.trim().charAt(0).toUpperCase() || '?'}
    </StyledAvatarFallback>
  )
}
