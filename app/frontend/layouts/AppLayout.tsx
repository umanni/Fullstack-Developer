import { Link, usePage } from '@inertiajs/react'
import { useState, type ReactNode } from 'react'

import { Avatar } from '@/components/Avatar'
import { FlashMessages } from '@/components/FlashMessages'
import { Icon, type IconName } from '@/components/Icon'
import { Logo } from '@/components/Logo'
import { classNames } from '@/lib/class-names'
import { routes } from '@/lib/routes'

type NavigationItem = { label: string; href: string; icon: IconName }

const adminNavigation: NavigationItem[] = [
  { label: 'Overview', href: routes.adminDashboard, icon: 'dashboard' },
  { label: 'Users', href: routes.adminUsers, icon: 'users' },
  { label: 'Imports', href: routes.adminImports, icon: 'import' },
]

const userNavigation: NavigationItem[] = [
  { label: 'My profile', href: routes.profile, icon: 'user' },
]

export function AppLayout({ children }: { children: ReactNode }) {
  const page = usePage()
  const user = page.props.auth.user
  const [menuOpen, setMenuOpen] = useState(false)

  if (!user) return null

  const navigation = user.role === 'admin' ? adminNavigation : userNavigation
  const isActive = (href: string) =>
    href === routes.adminDashboard
      ? page.url === href
      : page.url.startsWith(href)

  const navigationContent = (
    <>
      <div className="flex h-20 items-center px-5">
        <Logo />
      </div>
      <nav
        aria-label="Primary navigation"
        className="flex-1 space-y-1 px-3 py-5"
      >
        {navigation.map((item) => (
          <Link
            className={classNames(
              'flex min-h-11 items-center gap-3 rounded-xl px-3 text-sm font-semibold transition-colors',
              isActive(item.href)
                ? 'bg-brand-50 text-brand-800'
                : 'text-slate-600 hover:bg-slate-100 hover:text-slate-950',
            )}
            href={item.href}
            key={item.href}
            onClick={() => setMenuOpen(false)}
          >
            <Icon className="size-5" name={item.icon} />
            {item.label}
          </Link>
        ))}
      </nav>
      <div className="border-t border-slate-200 p-4">
        <div className="flex items-center gap-3 rounded-xl px-1 py-2">
          <Avatar name={user.full_name} size="sm" src={user.avatar_url} />
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-semibold text-slate-900">
              {user.full_name}
            </p>
            <p className="truncate text-xs text-slate-500">{user.email}</p>
          </div>
          <Link
            aria-label="Sign out"
            as="button"
            className="rounded-lg p-2 text-slate-500 hover:bg-slate-100 hover:text-slate-900 focus-visible:outline-2 focus-visible:outline-brand-500"
            href={routes.session}
            method="delete"
          >
            <Icon className="size-5" name="logout" />
          </Link>
        </div>
      </div>
    </>
  )

  return (
    <div className="min-h-screen bg-slate-50">
      <FlashMessages />
      <aside className="fixed inset-y-0 left-0 z-30 hidden w-64 border-r border-slate-200 bg-white lg:flex lg:flex-col">
        {navigationContent}
      </aside>

      {menuOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <button
            aria-label="Close navigation"
            className="absolute inset-0 bg-slate-950/30 backdrop-blur-sm"
            onClick={() => setMenuOpen(false)}
            type="button"
          />
          <aside className="relative flex h-full w-[min(88vw,20rem)] flex-col bg-white shadow-2xl">
            <button
              aria-label="Close navigation"
              className="absolute right-3 top-5 rounded-lg p-2 text-slate-500 hover:bg-slate-100"
              onClick={() => setMenuOpen(false)}
              type="button"
            >
              <Icon name="x" />
            </button>
            {navigationContent}
          </aside>
        </div>
      )}

      <div className="lg:pl-64">
        <header className="sticky top-0 z-20 flex h-16 items-center border-b border-slate-200 bg-white/90 px-4 backdrop-blur lg:hidden">
          <button
            aria-label="Open navigation"
            className="rounded-lg p-2 text-slate-600 hover:bg-slate-100"
            onClick={() => setMenuOpen(true)}
            type="button"
          >
            <Icon name="menu" />
          </button>
          <span className="ml-3 text-sm font-semibold text-slate-900">
            PeopleHub
          </span>
        </header>
        <main className="mx-auto max-w-7xl px-4 py-7 sm:px-6 sm:py-10 lg:px-8">
          {children}
        </main>
      </div>
    </div>
  )
}
