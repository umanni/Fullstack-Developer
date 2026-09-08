import { Head, Link, useForm } from '@inertiajs/react'
import { useState, type FormEvent } from 'react'

import { Button, ButtonLink } from '@/components/Button'
import { Icon } from '@/components/Icon'
import { PageHeader } from '@/components/PageHeader'
import { AppLayout } from '@/layouts/AppLayout'
import { routes } from '@/lib/routes'

export default function NewImport() {
  const form = useForm<{ spreadsheet: File | null }>({ spreadsheet: null })
  const [dragging, setDragging] = useState(false)
  const error = Array.isArray(form.errors.spreadsheet)
    ? form.errors.spreadsheet.join(', ')
    : form.errors.spreadsheet

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.transform((data) => ({ user_import: data }))
    form.post(routes.adminImports, { forceFormData: true })
  }

  return (
    <AppLayout>
      <Head title="Import users" />
      <PageHeader
        description="Create multiple users asynchronously from a validated CSV or XLSX file."
        eyebrow="User imports"
        title="Upload a spreadsheet"
      />

      <div className="mt-8 grid gap-6 lg:grid-cols-[minmax(0,1fr)_21rem]">
        <form
          className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-7"
          onSubmit={submit}
        >
          <label
            className={`flex min-h-64 cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed px-6 text-center transition-colors ${
              dragging
                ? 'border-brand-500 bg-brand-50'
                : 'border-slate-300 bg-slate-50 hover:border-brand-400 hover:bg-brand-50/40'
            }`}
            onDragEnter={() => setDragging(true)}
            onDragLeave={() => setDragging(false)}
            onDrop={() => setDragging(false)}
          >
            <span className="grid size-14 place-items-center rounded-2xl bg-white text-brand-700 shadow-sm">
              <Icon className="size-6" name="upload" />
            </span>
            <span className="mt-5 font-semibold text-slate-900">
              Choose a file or drag it here
            </span>
            <span className="mt-1 text-sm text-slate-500">
              CSV or XLSX, up to 10 MB and 5,000 rows
            </span>
            {form.data.spreadsheet && (
              <span className="mt-4 rounded-full bg-brand-100 px-3 py-1 text-sm font-medium text-brand-800">
                {form.data.spreadsheet.name}
              </span>
            )}
            <input
              accept=".csv,.xlsx,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
              className="sr-only"
              onChange={(event) =>
                form.setData('spreadsheet', event.target.files?.[0] ?? null)
              }
              required
              type="file"
            />
          </label>
          {error && <p className="mt-2 text-sm text-rose-600">{error}</p>}
          <div className="mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
            <ButtonLink href={routes.adminImports} variant="secondary">
              Cancel
            </ButtonLink>
            <Button
              disabled={!form.data.spreadsheet || form.processing}
              type="submit"
            >
              {form.processing ? 'Uploading…' : 'Start import'}
            </Button>
          </div>
        </form>

        <aside className="space-y-5">
          <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
            <h2 className="font-semibold text-slate-950">Required columns</h2>
            <div className="mt-4 overflow-hidden rounded-xl border border-slate-200 text-sm">
              <div className="grid grid-cols-[1fr_auto] bg-slate-50 px-3 py-2 font-semibold text-slate-700">
                <span>Column</span>
                <span>Required</span>
              </div>
              {[
                ['full_name', 'Yes'],
                ['email', 'Yes'],
                ['role', 'No'],
              ].map(([column, required]) => (
                <div
                  className="grid grid-cols-[1fr_auto] border-t border-slate-200 px-3 py-2"
                  key={column}
                >
                  <code className="text-brand-700">{column}</code>
                  <span className="text-slate-500">{required}</span>
                </div>
              ))}
            </div>
            <Link
              className="mt-4 inline-flex items-center gap-2 text-sm font-semibold text-brand-700 hover:text-brand-800"
              href="/user_import_template.csv"
            >
              <Icon className="size-4" name="file" /> Download CSV template
            </Link>
          </section>
          <section className="rounded-2xl bg-brand-950 p-5 text-brand-50">
            <h2 className="font-semibold text-white">How access works</h2>
            <p className="mt-2 text-sm leading-6 text-brand-100">
              Leave role empty for standard access. Use{' '}
              <code className="rounded bg-white/10 px-1">admin</code> only when
              needed. Each imported user receives a secure password-reset email.
            </p>
          </section>
        </aside>
      </div>
    </AppLayout>
  )
}
