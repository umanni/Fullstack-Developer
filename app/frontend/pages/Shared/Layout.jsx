import { Link, usePage } from "@inertiajs/react"

export default function Layout({ children }) {
  const { auth, flash } = usePage().props
  const user = auth?.user

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-white to-blue-50 text-slate-800 font-sans selection:bg-blue-200 selection:text-blue-900">
      <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-slate-200/60 shadow-sm">
        <nav className="container mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/" className="text-xl font-extrabold tracking-tight text-slate-900 hover:text-blue-700 transition-colors">
            Umanni Users
          </Link>
          <div className="flex items-center gap-3 text-sm font-medium">
            {user ? (
              <>
                {user.role === "admin" ? (
                  <>
                    <Link href="/admin" className="px-3 py-1.5 rounded-full hover:bg-blue-50 text-slate-600 hover:text-blue-700 transition">Dashboard</Link>
                    <Link href="/admin/users" className="px-3 py-1.5 rounded-full hover:bg-blue-50 text-slate-600 hover:text-blue-700 transition">Users</Link>
                    <Link href="/admin/user_imports" className="px-3 py-1.5 rounded-full hover:bg-blue-50 text-slate-600 hover:text-blue-700 transition">Imports</Link>
                  </>
                ) : (
                  <Link href="/profile" className="px-3 py-1.5 rounded-full hover:bg-blue-50 text-slate-600 hover:text-blue-700 transition">Profile</Link>
                )}
                <Link href="/session" method="delete" as="button" className="ml-2 px-4 py-1.5 rounded-full bg-slate-900 text-white hover:bg-slate-800 transition shadow-md shadow-slate-900/10">Sign out</Link>
              </>
            ) : (
              <>
                <Link href="/session/new" className="px-4 py-1.5 rounded-full hover:bg-slate-100 text-slate-600 transition">Sign in</Link>
                <Link href="/registration/new" className="px-4 py-1.5 rounded-full bg-gradient-to-r from-blue-600 to-indigo-600 text-white hover:from-blue-700 hover:to-indigo-700 transition shadow-lg shadow-blue-600/20">Sign up</Link>
              </>
            )}
          </div>
        </nav>
      </header>
      <main className="container mx-auto px-6 py-12 max-w-5xl">
        {flash?.notice && (
          <div className="mb-6 p-4 rounded-2xl bg-emerald-50 text-emerald-800 border border-emerald-100 shadow-sm animate-fade-in">
            {flash.notice}
          </div>
        )}
        {flash?.alert && (
          <div className="mb-6 p-4 rounded-2xl bg-rose-50 text-rose-800 border border-rose-100 shadow-sm animate-fade-in">
            {flash.alert}
          </div>
        )}
        <div className="bg-white/70 backdrop-blur-xl rounded-3xl shadow-xl shadow-slate-200/50 border border-white/40 p-8 md:p-12">
          {children}
        </div>
      </main>
      <footer className="text-center text-xs text-slate-400 py-8">
        Modern Fullstack Developer Test — Rails 8 / Ruby 4 / Inertia React
      </footer>
    </div>
  )
}
