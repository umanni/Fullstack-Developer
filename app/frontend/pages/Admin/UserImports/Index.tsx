import { Head, router, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { Field } from '@/molecules/Field/Field'
import { FieldGroup } from '@/molecules/FieldGroup/FieldGroup'
import { Form } from '@/molecules/Form/Form'
import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { ImportsTable } from '@/organisms/ImportsTable/ImportsTable'
import { Pagination } from '@/organisms/Pagination/Pagination'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminImportListItem, AdminPageUrls, Pagination as PaginationData } from '@/types'

type ImportsIndexProps = {
  imports: AdminImportListItem[]
  pagination: PaginationData
  urls: AdminPageUrls & { new_import_url: string }
}

export default function ImportsIndex({ imports, pagination, urls }: ImportsIndexProps) {
  const { data, setData } = useForm({ page: String(pagination.page) })

  function go(page: number) {
    router.reload({ data: { page: String(page) }, only: ['imports', 'pagination'] })
  }

  function handleSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const page = Number.parseInt(data.page, 10) || 1
    go(page)
  }

  return (
    <>
      <Head title="Admin · Imports" />
      <AdminLayout urls={urls}>
        <PageHeader
          title="Imports"
          action={
            <ButtonLink variant="secondary" href={urls.new_import_url}>
              New import
            </ButtonLink>
          }
        />
        <Form onSubmit={handleSearch}>
          <FieldGroup>
            <Field label="Go to page" htmlFor="imports_page">
              <TextInput
                id="imports_page"
                type="number"
                min={1}
                max={pagination.pages}
                value={data.page}
                onChange={(event) => setData('page', event.target.value)}
              />
            </Field>
            <Button type="submit" variant="secondary">
              Go
            </Button>
          </FieldGroup>
        </Form>
        <ImportsTable imports={imports} showCreated />
        <Pagination
          page={pagination.page}
          pages={pagination.pages}
          count={pagination.count}
          countLabel="imports"
          onPrevious={() => go(pagination.prev ?? 1)}
          onNext={() => go(pagination.next ?? 1)}
        />
      </AdminLayout>
    </>
  )
}
