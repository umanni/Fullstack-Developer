import { Link, router } from "@inertiajs/react"
import { useEffect } from "react"
import Layout from "../../Shared/Layout"

export default function Show({ import: imp }) {
  useEffect(() => {
    if (imp.status === "pending" || imp.status === "processing") {
      const id = setInterval(() => router.reload({ only: ["import"] }), 2000)
      return () => clearInterval(id)
    }
  }, [imp.status])

  return (
    <div className="mx-auto max-w-2xl py-8">
      <h1 className="font-bold text-2xl mb-4">Import {imp.id}</h1>
      <p>Status: {imp.status}</p>
      <p>Total: {imp.total_rows}</p>
      <p>Processed: {imp.processed_rows}</p>
      <p>Failed: {imp.failed_rows}</p>
      <p><Link href="/admin/user_imports" className="underline">Back</Link></p>
    </div>
  )
}

Show.layout = (page) => <Layout>{page}</Layout>
