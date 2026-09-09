import { Link, usePage } from "@inertiajs/react"

export default function Layout({ children }) {
  const { auth, flash } = usePage().props
  const user = auth?.user

  return (
    <div>
      <header className="border-b">
        <nav className="container mx-auto px-5 py-3 flex items-center gap-4 text-sm">
          <Link href="/" className="font-bold">Home</Link>
          {user ? (
            <>
              {user.role === "admin" ? (
                <>
                  <Link href="/admin">Dashboard</Link>
                  <Link href="/admin/users">Users</Link>
                  <Link href="/admin/user_imports">Imports</Link>
                </>
              ) : (
                <Link href="/profile">Profile</Link>
              )}
              <Link href="/session" method="delete" as="button" className="ml-auto underline">Sign out</Link>
            </>
          ) : (
            <>
              <Link href="/session/new" className="ml-auto">Sign in</Link>
              <Link href="/registration/new" className="rounded bg-blue-600 text-white px-3 py-1">Sign up</Link>
            </>
          )}
        </nav>
      </header>
      <main className="container mx-auto mt-10 px-5">
        {flash?.notice && <p className="bg-green-50 text-green-700 px-3 py-2 rounded mb-4">{flash.notice}</p>}
        {flash?.alert && <p className="bg-red-50 text-red-500 px-3 py-2 rounded mb-4">{flash.alert}</p>}
        {children}
      </main>
    </div>
  )
}
