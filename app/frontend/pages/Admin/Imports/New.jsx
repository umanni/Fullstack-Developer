import { useForm } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ user_import: { file: null } })

  function submit(e) {
    e.preventDefault()
    post("/admin/user_imports")
  }

  return (
    <div className="mx-auto max-w-2xl py-8">
      <h1 className="font-bold text-2xl mb-4">Import users</h1>
      <form onSubmit={submit}>
        <input type="file" accept=".csv,.xlsx" required onChange={(e) => setData("user_import", { file: e.target.files[0] })} />
        {errors.file && <p className="text-red-600 text-sm">{errors.file}</p>}
        <button disabled={processing} className="ml-2 bg-blue-600 text-white rounded px-3 py-2">Upload</button>
      </form>
    </div>
  )
}

New.layout = (page) => <Layout>{page}</Layout>
