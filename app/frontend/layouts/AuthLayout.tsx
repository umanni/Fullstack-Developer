import type { ReactNode } from 'react'

import { FlashMessages } from '@/components/FlashMessages'
import { Logo } from '@/components/Logo'

export function AuthLayout({
  children,
  title,
  description,
}: {
  children: ReactNode
  title: string
  description: string
}) {
  return (
    <div className="relative flex min-h-screen bg-slate-50">
      <FlashMessages />
      <aside className="relative hidden w-[44%] overflow-hidden bg-brand-950 lg:flex lg:flex-col lg:justify-between lg:p-12 xl:p-16">
        <div className="absolute -left-24 top-1/3 size-80 rounded-full bg-brand-500/15 blur-3xl" />
        <div className="absolute -right-20 -top-16 size-96 rounded-full bg-brand-400/10 blur-3xl" />
        <div className="relative">
          <div className="[&_span:last-child]:text-white">
            <Logo />
          </div>
        </div>
        <div className="relative max-w-lg">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-brand-300">
            People operations, simplified
          </p>
          <blockquote className="mt-6 text-3xl font-semibold leading-tight tracking-tight text-white xl:text-4xl">
            Give your team a clear, secure home for every people record.
          </blockquote>
          <div className="mt-9 grid grid-cols-3 gap-3 text-sm text-brand-100">
            {['Live insights', 'Secure access', 'Fast imports'].map((item) => (
              <div
                className="rounded-xl border border-white/10 bg-white/5 p-3"
                key={item}
              >
                {item}
              </div>
            ))}
          </div>
        </div>
        <p className="relative text-xs text-brand-200/70">
          Built for focused people teams.
        </p>
      </aside>

      <main className="flex flex-1 items-center justify-center px-5 py-10 sm:px-8">
        <div className="w-full max-w-md">
          <div className="mb-10 lg:hidden">
            <Logo />
          </div>
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm sm:p-9">
            <h1 className="text-2xl font-bold tracking-tight text-slate-950">
              {title}
            </h1>
            <p className="mt-2 text-sm leading-6 text-slate-600">
              {description}
            </p>
            <div className="mt-8">{children}</div>
          </div>
        </div>
      </main>
    </div>
  )
}
