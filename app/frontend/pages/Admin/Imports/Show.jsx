import { Link } from "@inertiajs/react"
import { useEffect, useState } from "react"
import Layout from "../../Shared/Layout"
import { subscribe } from "../../../lib/cable"

export default function Show({ import: initial }) {
  const [imp, setImp] = useState(initial)

  useEffect(() => {
    const sub = subscribe("UserImportChannel", { id: initial.id }, (data) => setImp((prev) => ({ ...prev, ...data })))
    return () => sub.unsubscribe()
  }, [initial.id])

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
