import { Badge } from '@/atoms/Badge/Badge'
import type { BadgeVariant } from '@/atoms/Badge/Badge.types'
import type { ImportStatus } from '@/types'

export type ImportStatusBadgeProps = {
  status: ImportStatus
}

const VARIANT: Record<ImportStatus, BadgeVariant> = {
  pending: 'pending',
  processing: 'processing',
  completed: 'completed',
  failed: 'failed',
}

const LABEL: Record<ImportStatus, string> = {
  pending: 'Pending',
  processing: 'Processing',
  completed: 'Completed',
  failed: 'Failed',
}

// Humanized import state chip. data-status stays on the DOM for tests/selectors.
export function ImportStatusBadge({ status }: ImportStatusBadgeProps) {
  return (
    <Badge variant={VARIANT[status]} data-status={status}>
      {LABEL[status]}
    </Badge>
  )
}
