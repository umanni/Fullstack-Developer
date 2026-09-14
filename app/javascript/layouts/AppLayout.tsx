import { Link, router, usePage } from '@inertiajs/react'
import { PropsWithChildren, useEffect, useId, useState } from 'react'
import type { SharedProps } from '@/types'

type NavLink = {
  href: string
  label: string
  fullReload?: boolean
}

function NavItem({ link, className }: { link: NavLink; className: string }) {
  return link.fullReload ? (
    <a href={link.href} className={className}>
      {link.label}
    </a>
  ) : (
    <Link href={link.href} className={className}>
      {link.label}
    </Link>
  )
}

export default function AppLayout({ children }: PropsWithChildren) {
  const { auth, flash } = usePage<SharedProps>().props
  const [banner, setBanner] = useState(flash.notice || flash.alert)
  const [menuOpen, setMenuOpen] = useState(false)
  const menuId = useId()

  useEffect(() => setBanner(flash.notice || flash.alert), [flash])

  // Close the phone menu once a visit lands, so it never sits over the next page.
  useEffect(() => router.on('navigate', () => setMenuOpen(false)), [])

  const links: NavLink[] = auth.user
    ? [
        ...(auth.user.admin
          ? [
              { href: '/admin', label: 'Dashboard' },
              { href: '/admin/users', label: 'Users' },
            ]
          : []),
        { href: '/profile', label: auth.user.full_name },
      ]
    : [
        { href: '/session/new', label: 'Sign in', fullReload: true },
        { href: '/registration/new', label: 'Create account' },
      ]

  return (
    <div className="flex min-h-dvh flex-col bg-slate-50 text-slate-900">
      <header className="safe-pt border-b border-slate-200 bg-white">
        <nav
          aria-label="Main"
          className="safe-px mx-auto flex w-full max-w-6xl items-center justify-between gap-4 py-2 sm:py-3"
        >
          <Link href="/" className="py-2 font-semibold tracking-tight">
            Umanni
          </Link>

          <div className="hidden items-center gap-4 text-sm sm:flex">
            {links.map((link) => (
              <NavItem key={link.href} link={link} className="hover:underline" />
            ))}
            {auth.user && (
              <Link
                href="/session"
                method="delete"
                as="button"
                className="text-slate-500 hover:underline"
              >
                Sign out
              </Link>
            )}
          </div>

          <button
            type="button"
            onClick={() => setMenuOpen((open) => !open)}
            aria-expanded={menuOpen}
            aria-controls={menuId}
            className="-mr-2 grid size-11 place-items-center rounded-md text-slate-700 hover:bg-slate-100 sm:hidden"
          >
            <span className="sr-only">{menuOpen ? 'Close menu' : 'Open menu'}</span>
            <svg
              aria-hidden
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              strokeLinecap="round"
              className="size-6"
            >
              {menuOpen ? <path d="M6 6l12 12M18 6L6 18" /> : <path d="M4 7h16M4 12h16M4 17h16" />}
            </svg>
          </button>
        </nav>

        <div
          id={menuId}
          hidden={!menuOpen}
          className="safe-px border-t border-slate-100 pb-2 sm:hidden"
        >
          <ul className="mx-auto max-w-6xl">
            {links.map((link) => (
              <li key={link.href}>
                <NavItem link={link} className="block py-3 text-base" />
              </li>
            ))}
            {auth.user && (
              <li>
                <Link
                  href="/session"
                  method="delete"
                  as="button"
                  className="block w-full py-3 text-left text-base text-slate-500"
                >
                  Sign out
                </Link>
              </li>
            )}
          </ul>
        </div>
      </header>

      {banner && (
        <div className="safe-px mx-auto mt-4 w-full max-w-6xl">
          <div
            role="status"
            className={`rounded-md px-4 py-3 text-sm ${
              flash.alert ? 'bg-red-50 text-red-800' : 'bg-emerald-50 text-emerald-800'
            }`}
          >
            {banner}
          </div>
        </div>
      )}

      <main className="safe-px safe-pb mx-auto w-full max-w-6xl flex-1 pt-6 sm:pt-8">
        {children}
      </main>
    </div>
  )
}
