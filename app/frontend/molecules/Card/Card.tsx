import type { ReactNode } from 'react'

import { StyledCard } from './Card.styles'

export type CardProps = {
  children: ReactNode
}

// Bordered surface for content panels (details, profiles, inline sections).
export function Card({ children }: CardProps) {
  return <StyledCard>{children}</StyledCard>
}
