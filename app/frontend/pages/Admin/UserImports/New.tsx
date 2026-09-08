import { Head, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'
import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { ImportsTable } from '@/organisms/ImportsTable/ImportsTable'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminImportListItem, AdminPageUrls } from '@/types'

type ImportFormUrls = AdminPageUrls & { submit_url: string }

type ImportsNewProps = {
  imports: AdminImportListItem[]
  errors?: Record<string, string[]>
  urls: ImportFormUrls
}

export default function ImportsNew({ imports, errors, urls }: ImportsNewProps) {
  const { setData, post, processing } = useForm<{ file: File | null }>({ file: null })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    post(urls.submit_url, { forceFormData: true })
  }

  return (
    <>
      <Head title="Admin · Import users" />
      <AdminLayout urls={urls}>
        <PageHeader
          title="Import users"
          action={
            <ButtonLink variant="secondary" href={urls.imports_url}>
              All imports
            </ButtonLink>
          }
        />
        <Form onSubmit={handleSubmit}>
          <Field
            label="Spreadsheet (.csv / .xlsx / .xls)"
            htmlFor="import_file"
            hint="Use a header row with Full name and Email address. Duplicate emails are skipped."
            error={errors?.file?.[0]}
          >
            <TextInput
              id="import_file"
              type="file"
              name="file"
              accept=".csv,.xlsx,.xls,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-excel"
              onChange={(event) => setData('file', event.target.files?.[0] ?? null)}
            />
          </Field>
          <Button type="submit" disabled={processing}>
            {processing ? 'Uploading…' : 'Upload and import'}
          </Button>
        </Form>
        <section>
          <PageHeader title="Recent imports" size="md" />
          <ImportsTable imports={imports} />
        </section>
      </AdminLayout>
    </>
  )
}
