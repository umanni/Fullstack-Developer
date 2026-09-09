import { Link } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

export default function Index({ imports }) {
  return (
    <div className="mx-auto max-w-2xl py-8">
      <h1 className="font-bold text-2xl mb-4">Imports</h1>
      <Link href="/admin/user_imports/new" className="bg-blue-600 text-white rounded px-3 py-2">New import</Link>
      <ul className="mt-4">
        {imports.map((imp) => (
          <li key={imp.id}><Link href={`/admin/user_imports/${imp.id}`} className="underline">Import {imp.id} - {imp.status}</Link></li>
        ))}
      </ul>
    </div>
  )
}

Index.layout = (page) => <Layout>{page}</Layout>
