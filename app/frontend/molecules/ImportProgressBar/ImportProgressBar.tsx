import { observer } from 'mobx-react-lite'
import { useEffect } from 'react'

import { ProgressBar } from '@/atoms/ProgressBar/ProgressBar'
import type { ProgressVariant } from '@/atoms/ProgressBar/ProgressBar.types'
import { useChannel } from '@/lib/cable'
import { useStore } from '@/stores'
import type { AdminImport, ImportStatus } from '@/types'
import { ImportStatusBadge } from '@/molecules/ImportStatusBadge/ImportStatusBadge'
import { DetailRow } from '@/molecules/DetailRow/DetailRow'
import type { ImportProgress } from '@/stores/imports-store'

import { StyledFeedback, StyledProgressWrap } from './ImportProgressBar.styles'

type ImportProgressBarProps = {
  importId: number
  initial: AdminImport
}

// Presenter (AdminImport) -> store canonical shape. Done once here so the
// store never learns about the HTTP serialization (single shape in state).
function toProgress(userImport: AdminImport): ImportProgress {
  return {
    id: userImport.id,
    status: userImport.status,
    total: userImport.total_rows,
    processed: userImport.processed_rows,
    failed: userImport.failed_rows,
    percent: userImport.progress,
  }
}

function feedbackFor(status: ImportStatus): string | null {
  switch (status) {
    case 'completed':
      return 'Import finished.'
    case 'failed':
      return 'Import finished with errors.'
    default:
      return null
  }
}

function fillVariantFor(status: ImportStatus): ProgressVariant {
  if (status === 'failed') return 'failed'
  if (status === 'completed') return 'completed'
  return 'default'
}

// Live import progress: hydrated from the initial props (fallback = same state
// as the render) and updated by the import_progress stream. Reactivity is
// pure MobX (observer + actions) — the websocket only feeds store.ingest.
export const ImportProgressBar = observer(function ImportProgressBar({
  importId,
  initial,
}: ImportProgressBarProps) {
  const { imports } = useStore()

  useEffect(() => {
    imports.hydrate(importId, toProgress(initial))
  }, [importId, imports, initial])

  useChannel<ImportProgress>('ImportProgressChannel', { import_id: importId }, (payload) => {
    imports.ingest(payload)
  })

  const live = imports.progressOf(importId)
  const display = live ?? toProgress(initial)
  const feedback = feedbackFor(display.status)

  return (
    <>
      <DetailRow label="Status">
        <ImportStatusBadge status={display.status} />
        {feedback ? <StyledFeedback>{feedback}</StyledFeedback> : null}
      </DetailRow>
      <DetailRow label="Progress">
        <StyledProgressWrap>
          <ProgressBar
            percent={display.percent}
            variant={fillVariantFor(display.status)}
            aria-label="Import progress"
          />
        </StyledProgressWrap>
        {display.percent}%
      </DetailRow>
      <DetailRow label="Rows">
        {display.processed} processed · {display.failed} failed · {display.total} total
      </DetailRow>
    </>
  )
})
