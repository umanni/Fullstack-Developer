import type { ReactNode } from 'react'

import type { AdminPageUrls } from '@/types'
import { FlashMessages } from '@/organisms/FlashMessages/FlashMessages'
import { Navbar } from '@/organisms/Navbar/Navbar'

import { StyledMain, StyledShell } from './AdminLayout.styles'

export type AdminLayoutProps = {
  urls: AdminPageUrls
  children: ReactNode
}

// Admin-area shell: navigation + flash + constrained content column.
export function AdminLayout({ urls, children }: AdminLayoutProps) {
  return (
    <StyledShell>
      <Navbar
        title="IAM Admin"
        links={[
          { label: 'Dashboard', href: urls.dashboard_url },
          { label: 'Users', href: urls.users_url },
          { label: 'Imports', href: urls.imports_url },
        ]}
      />
      <StyledMain>
        <FlashMessages />
        {children}
      </StyledMain>
    </StyledShell>
  )
}
