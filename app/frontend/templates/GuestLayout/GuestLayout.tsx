import type { ReactNode } from 'react'

import { Heading } from '@/atoms/Heading/Heading'
import { FlashMessages } from '@/organisms/FlashMessages/FlashMessages'

import { StyledBrand, StyledCard, StyledLinks, StyledMain, StyledShell } from './GuestLayout.styles'

export type GuestLayoutProps = {
  title: string
  brand?: string
  children: ReactNode
  links?: ReactNode
}

// Frameless (pre-auth) shell: centered card with flash and optional text links.
export function GuestLayout({ title, brand = 'IAM', children, links }: GuestLayoutProps) {
  return (
    <StyledShell>
      <StyledMain>
        <StyledBrand>{brand}</StyledBrand>
        <StyledCard>
          <FlashMessages />
          <Heading>{title}</Heading>
          {children}
        </StyledCard>
        {links ? <StyledLinks>{links}</StyledLinks> : null}
      </StyledMain>
    </StyledShell>
  )
}
