import { Head, Link } from '@inertiajs/react'

import { ButtonLink } from '@/components/Button'
import { EmptyState } from '@/components/EmptyState'
import { Icon } from '@/components/Icon'
import { ImportSummary } from '@/components/ImportSummary'
import { PageHeader } from '@/components/PageHeader'
import { AppLayout } from '@/layouts/AppLayout'
import { routes } from '@/lib/routes'
import type { UserImport } from '@/types'

export default function ImportsIndex({ imports }: { imports: UserImport[] }) {
  return (
    <AppLayout>
      <Head title="User imports" />
      <PageHeader
        actions={
          <ButtonLink href={routes.newAdminImport}>
            <Icon className="size-4" name="upload" /> New import
          </ButtonLink>
        }
        description="Track spreadsheet jobs and inspect row-level errors."
        eyebrow="Administration"
        title="User imports"
      />

      <section className="mt-8">
        {imports.length === 0 ? (
          <EmptyState
            action={
              <ButtonLink href={routes.newAdminImport}>
                <Icon className="size-4" name="upload" /> Upload spreadsheet
              </ButtonLink>
            }
            description="Import a CSV or XLSX spreadsheet to create users in the background."
            icon="import"
            title="No import history"
          />
        ) : (
          <ul className="grid gap-4 lg:grid-cols-2">
            {imports.map((item) => (
              <li
                className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition-shadow hover:shadow-md sm:p-6"
                key={item.id}
              >
                <Link
                  className="block rounded-xl focus-visible:outline-2 focus-visible:outline-brand-500"
                  href={routes.adminImport(item.id)}
                >
                  <ImportSummary item={item} />
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>
    </AppLayout>
  )
}
