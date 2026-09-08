import { observer } from 'mobx-react-lite'
import type { ReactNode } from 'react'

import { useStore } from '@/stores'
import { Navbar } from '@/organisms/Navbar/Navbar'
import { FlashMessages } from '@/organisms/FlashMessages/FlashMessages'

import { StyledMain, StyledShell } from './AuthenticatedLayout.styles'

export type AuthenticatedLayoutProps = {
  navTitle?: string
  profileUrl: string
  adminUrl?: string
  children: ReactNode
}

// Post-login shell for non-admin areas (profile). Admin visibility comes from
// the SessionStore (single source of truth), so no prop drilling of roles.
export const AuthenticatedLayout = observer(function AuthenticatedLayout({
  navTitle = 'IAM',
  profileUrl,
  adminUrl,
  children,
}: AuthenticatedLayoutProps) {
  const { session } = useStore()

  const links = [{ label: 'Profile', href: profileUrl }]
  if (session.isAdmin && adminUrl) {
    links.push({ label: 'Admin panel', href: adminUrl })
  }

  return (
    <StyledShell>
      <Navbar title={navTitle} links={links} />
      <StyledMain>
        <FlashMessages />
        {children}
      </StyledMain>
    </StyledShell>
  )
})
