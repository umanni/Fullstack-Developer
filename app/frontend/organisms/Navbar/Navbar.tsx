import { router } from '@inertiajs/react'
import { useEffect, useRef, useState } from 'react'

import { Button } from '@/atoms/Button/Button'
import { Icon } from '@/atoms/Icon/Icon'

import {
  StyledBrand,
  StyledHeader,
  StyledMenuButton,
  StyledMobileLink,
  StyledMobilePanel,
  StyledMobileSignOut,
  StyledMobileSignOutButton,
  StyledNav,
  StyledNavLink,
  StyledSignOut,
  StyledSpacer,
} from './Navbar.styles'

export type NavLink = {
  label: string
  href: string
}

export type NavbarProps = {
  title: string
  links: NavLink[]
  signOutUrl?: string
}

// Top navigation bar for authenticated layouts. Links use Inertia <Link>
// (SPA); sign out issues a DELETE via the shared navigation lifecycle. Below
// the `sm` breakpoint the links collapse into a hamburger dropdown panel.
export function Navbar({ title, links, signOutUrl = '/session' }: NavbarProps) {
  const [menuOpen, setMenuOpen] = useState(false)
  const headerRef = useRef<HTMLElement | null>(null)
  const closeMenu = () => setMenuOpen(false)

  useEffect(() => {
    if (!menuOpen) return

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') setMenuOpen(false)
    }

    function handlePointerDown(event: PointerEvent) {
      if (!headerRef.current?.contains(event.target as Node)) setMenuOpen(false)
    }

    document.addEventListener('keydown', handleKeyDown)
    document.addEventListener('pointerdown', handlePointerDown, true)
    return () => {
      document.removeEventListener('keydown', handleKeyDown)
      document.removeEventListener('pointerdown', handlePointerDown, true)
    }
  }, [menuOpen])

  return (
    <StyledHeader ref={headerRef}>
      <StyledBrand>{title}</StyledBrand>
      <StyledNav>
        {links.map((link) => (
          <StyledNavLink key={link.href} href={link.href}>
            {link.label}
          </StyledNavLink>
        ))}
      </StyledNav>
      <StyledSpacer />
      <StyledSignOut>
        <Button
          variant="secondary"
          size="sm"
          type="button"
          onClick={() => router.delete(signOutUrl)}
        >
          <Icon name="logout" size="sm" />
          Sign out
        </Button>
      </StyledSignOut>
      <StyledMenuButton
        type="button"
        aria-label="Toggle navigation"
        aria-expanded={menuOpen}
        aria-controls="navbar-mobile-menu"
        onClick={() => setMenuOpen((open) => !open)}
      >
        <Icon name={menuOpen ? 'x' : 'menu'} size="md" />
      </StyledMenuButton>
      {menuOpen ? (
        <StyledMobilePanel id="navbar-mobile-menu">
          {links.map((link) => (
            <StyledMobileLink key={link.href} href={link.href} onClick={closeMenu}>
              {link.label}
            </StyledMobileLink>
          ))}
          <StyledMobileSignOut>
            <StyledMobileSignOutButton
              variant="secondary"
              size="sm"
              type="button"
              onClick={() => router.delete(signOutUrl)}
            >
              <Icon name="logout" size="sm" />
              Sign out
            </StyledMobileSignOutButton>
          </StyledMobileSignOut>
        </StyledMobilePanel>
      ) : null}
    </StyledHeader>
  )
}
