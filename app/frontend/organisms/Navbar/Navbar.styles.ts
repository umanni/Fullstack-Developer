import { Link } from '@inertiajs/react'
import type { InertiaLinkProps } from '@inertiajs/react'
import type { ForwardRefExoticComponent, RefAttributes } from 'react'

import { Button } from '@/atoms/Button/Button'
import { styled } from '@/lib/styled'

export const StyledHeader = styled.header(
  'sticky top-0 z-10 flex items-center gap-4 border-b border-line bg-paper px-4 py-3 shadow-sm sm:gap-6 sm:px-6',
)

export const StyledBrand = styled.span(
  'min-w-0 truncate text-sm font-bold uppercase tracking-wider text-ink',
)

// Inline links: hidden below `sm`, where the hamburger menu takes over.
export const StyledNav = styled.nav('hidden items-center gap-5 sm:flex')

// SPA link via Inertia (never a plain anchor) with header-nav styling.
export type StyledNavLinkProps = InertiaLinkProps & { className?: string }

export const StyledNavLink = styled(
  Link,
  'shrink-0 text-sm font-medium text-ink-soft transition-colors hover:text-ink',
) as ForwardRefExoticComponent<StyledNavLinkProps & RefAttributes<unknown>>

export const StyledSpacer = styled.span('min-w-0 flex-1')

// Desktop-only sign-out; mobile gets the action inside the dropdown panel.
export const StyledSignOut = styled.span('hidden sm:block')

export const StyledMenuButton = styled.button(
  'inline-flex items-center justify-center rounded-md border border-line bg-paper p-2 text-ink transition-colors hover:bg-line-soft focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-ring sm:hidden',
)

export const StyledMobilePanel = styled.div(
  'absolute inset-x-0 top-full z-10 border-b border-line bg-paper px-4 pb-3 pt-2 shadow-pop sm:hidden',
)

export const StyledMobileLink = styled(
  Link,
  'block rounded-md px-3 py-2.5 text-sm font-medium text-ink-soft transition-colors hover:bg-line-soft hover:text-ink focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-ring',
) as ForwardRefExoticComponent<StyledNavLinkProps & RefAttributes<unknown>>

export const StyledMobileSignOut = styled.div('mt-2 border-t border-line pt-2')

// Full-width sign-out for the mobile dropdown (style rule: utility classes
// stay in *.styles.ts).
export const StyledMobileSignOutButton = styled(Button, 'w-full')
