import { Head, Link } from '@inertiajs/react'
import AppLayout from '@/layouts/AppLayout'

export default function Home() {
  return (
    <>
      <Head title="Welcome" />

      <section className="mx-auto max-w-xl py-8 text-center sm:py-16">
        <h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">Welcome to Umanni</h1>
        <p className="mt-4 text-slate-600">
          Create an account to set up your profile, or sign in if you already have one.
        </p>

        <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:justify-center">
          <Link
            href="/registration/new"
            className="rounded-md bg-slate-900 px-4 py-2.5 text-sm text-white hover:bg-slate-700"
          >
            Create account
          </Link>
          {/* The sign-in page is a plain Rails view, not an Inertia page, so it needs a full page load. */}
          <a
            href="/session/new"
            className="rounded-md border border-slate-300 bg-white px-4 py-2.5 text-sm hover:bg-slate-100"
          >
            Sign in
          </a>
        </div>
      </section>
    </>
  )
}

Home.layout = AppLayout
