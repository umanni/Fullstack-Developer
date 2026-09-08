import { Head } from '@inertiajs/react'

import { Alert } from '@/atoms/Alert/Alert'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { Card } from '@/molecules/Card/Card'
import { DetailRow } from '@/molecules/DetailRow/DetailRow'
import { ImportProgressBar } from '@/molecules/ImportProgressBar/ImportProgressBar'
import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { AdminLayout } from '@/templates/AdminLayout/AdminLayout'
import type { AdminImport, AdminPageUrls } from '@/types'

type ImportShowProps = {
  import: AdminImport
  urls: AdminPageUrls & { imports_url: string }
}

export default function ImportShow({ import: userImport, urls }: ImportShowProps) {
  return (
    <>
      <Head title={`Import ${userImport.file_name ?? userImport.id}`} />
      <AdminLayout urls={urls}>
        <PageHeader
          title={userImport.file_name ?? `Import #${userImport.id}`}
          action={
            <ButtonLink variant="secondary" href={urls.imports_url}>
              Back to imports
            </ButtonLink>
          }
        />
        <Card>
          <ImportProgressBar importId={userImport.id} initial={userImport} />
          <DetailRow label="Created at">{userImport.created_at}</DetailRow>
          <DetailRow label="Finished at">{userImport.finished_at ?? '—'}</DetailRow>
          {userImport.error_message ? (
            <DetailRow label="Errors">
              <Alert variant="danger">{userImport.error_message}</Alert>
            </DetailRow>
          ) : null}
        </Card>
      </AdminLayout>
    </>
  )
}
