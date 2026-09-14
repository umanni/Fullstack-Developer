import { Head, Link, useForm } from '@inertiajs/react'
import { FormEvent } from 'react'
import AppLayout from '@/layouts/AppLayout'
import Field from '@/components/Field'
import { useLiveValidation } from '@/hooks/useLiveValidation'
import { spreadsheet } from '@/lib/validation'

/** Mirrors Imports::UserRow::HEADER_ALIASES and the row validations. */
const COLUMNS = [
  { name: 'full_name', aliases: 'name, fullname, nome', notes: 'Required, 2 to 120 characters.' },
  {
    name: 'email',
    aliases: 'email_address, e-mail',
    notes: 'Required. Rows for an email that already has an account are skipped.',
  },
  { name: 'role', aliases: 'perfil', notes: 'admin or member, in lowercase. Blank means member.' },
  { name: 'avatar_url', aliases: 'avatar, photo', notes: 'Optional https:// link.' },
]

export default function New() {
  const form = useForm({ file: null as File | null })
  const { errors, processing, progress } = form
  const validation = useLiveValidation(form, { file: spreadsheet })

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (!validation.validate(event.currentTarget)) return

    // Rails only wraps JSON bodies under the model key, so the multipart upload has
    // to arrive already nested to satisfy `params.expect(import: [ :file ])`.
    form.transform(({ file }) => ({ import: { file } }))
    form.post('/admin/imports', { forceFormData: true })
  }

  return (
    <>
      <Head title="Import users" />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-semibold tracking-tight">Import users</h1>
        <div className="flex items-center gap-4 text-sm">
          <Link href="/admin/imports" className="text-slate-600 hover:underline">
            Past imports
          </Link>
          <Link href="/admin/users" className="text-slate-600 hover:underline">
            Back to users
          </Link>
        </div>
      </div>

      <form onSubmit={submit} className="mt-6 max-w-lg space-y-4" noValidate>
        <Field
          label="Spreadsheet"
          error={errors.file}
          hint="A .csv or .xlsx file up to 10 MB, with column names in the first row."
        >
          <input
            type="file"
            accept=".csv,.xlsx,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            onChange={(e) => validation.update('file', e.target.files?.[0] ?? null, true)}
            className="text-sm"
          />
        </Field>

        {progress && (
          <progress value={progress.percentage ?? 0} max={100} className="w-full">
            {progress.percentage}%
          </progress>
        )}

        <button
          type="submit"
          disabled={processing}
          className="rounded-md bg-slate-900 px-4 py-2 text-sm text-white hover:bg-slate-700 disabled:opacity-50"
        >
          {processing ? 'Uploading...' : 'Start import'}
        </button>
      </form>

      <section className="mt-10 max-w-3xl">
        <h2 className="text-lg font-medium">Columns</h2>
        <p className="mt-1 text-sm text-slate-500">
          Column names are matched regardless of case, spacing or punctuation. Any other column is
          ignored.
        </p>
        <div className="mt-3 overflow-x-auto rounded-lg border border-slate-200 bg-white">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-slate-200 text-xs uppercase text-slate-500">
              <tr>
                <th scope="col" className="px-4 py-3">
                  Column
                </th>
                <th scope="col" className="px-4 py-3">
                  Also accepted
                </th>
                <th scope="col" className="px-4 py-3">
                  Notes
                </th>
              </tr>
            </thead>
            <tbody>
              {COLUMNS.map((column) => (
                <tr key={column.name} className="border-b border-slate-100 last:border-0 align-top">
                  <td className="px-4 py-3 font-mono text-xs text-slate-900">{column.name}</td>
                  <td className="px-4 py-3 font-mono text-xs text-slate-500">{column.aliases}</td>
                  <td className="px-4 py-3 text-slate-600">{column.notes}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </>
  )
}

New.layout = AppLayout
