import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { EmptyState } from '@/atoms/EmptyState/EmptyState'
import { ImportStatusBadge } from '@/molecules/ImportStatusBadge/ImportStatusBadge'
import type { AdminImportListItem } from '@/types'

import {
  StyledCell,
  StyledHead,
  StyledHeadCell,
  StyledRow,
  StyledScroll,
  StyledTable,
} from './ImportsTable.styles'

export type ImportsTableProps = {
  imports: AdminImportListItem[]
  showCreated?: boolean
}

// Import listings for both the recent-imports summary and the full index.
export function ImportsTable({ imports, showCreated = false }: ImportsTableProps) {
  if (imports.length === 0) {
    return (
      <EmptyState
        icon="upload"
        title="No imports yet"
        description="Upload a spreadsheet to get started."
      />
    )
  }

  return (
    <StyledScroll>
      <StyledTable>
        <StyledHead>
          <tr>
            <StyledHeadCell>File</StyledHeadCell>
            <StyledHeadCell>Status</StyledHeadCell>
            <StyledHeadCell>Rows</StyledHeadCell>
            <StyledHeadCell>Progress</StyledHeadCell>
            {showCreated ? <StyledHeadCell>Created</StyledHeadCell> : null}
          </tr>
        </StyledHead>
        <tbody>
          {imports.map((item) => (
            <StyledRow key={item.id}>
              <StyledCell>
                <ButtonLink href={item.show_url} variant="ghost" size="sm">
                  {item.file_name ?? `Import #${item.id}`}
                </ButtonLink>
              </StyledCell>
              <StyledCell>
                <ImportStatusBadge status={item.status} />
              </StyledCell>
              <StyledCell>
                {item.processed_rows}/{item.total_rows}
              </StyledCell>
              <StyledCell>{item.progress}%</StyledCell>
              {showCreated ? <StyledCell>{item.created_at}</StyledCell> : null}
            </StyledRow>
          ))}
        </tbody>
      </StyledTable>
    </StyledScroll>
  )
}
