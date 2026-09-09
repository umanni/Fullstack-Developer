import { useForm } from "@inertiajs/react"
import Layout from "../../Shared/Layout"

export default function New() {
  const { data, setData, post, processing, errors } = useForm({ user_import: { file: null } })
  function submit(e) { e.preventDefault(); if (window.confirm("Upload spreadsheet?")) post("/admin/user_imports") }
  return (
    <div className="max-w-xl mx-auto">
      <h1 className="text-4xl font-extrabold tracking-tight text-slate-900 mb-2">Import users</h1>
      <p className="text-slate-500 mb-8">Upload a .csv or .xlsx spreadsheet.</p>
      <form onSubmit={submit} className="space-y-4">
        <label className="block text-sm font-medium text-slate-700">Spreadsheet file (.csv or .xlsx)</label>
        <input type="file" accept=".csv,.xlsx" required onChange={(e) => setData("user_import", { file: e.target.files[0] })} className="block w-full text-sm text-slate-600 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100" />
        {errors.file && <p className="text-rose-600 text-sm">{errors.file}</p>}
        <button disabled={processing} className="rounded-2xl bg-gradient-to-r from-violet-600 to-fuchsia-600 text-white font-semibold px-5 py-3 shadow-lg shadow-violet-600/20 hover:shadow-violet-600/40 transition">Upload</button>
      </form>
    </div>
  )
}
New.layout = (page) => <Layout>{page}</Layout>
