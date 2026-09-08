import { Button } from '@/atoms/Button/Button'

import { StyledNavigation, StyledSummary } from './Pagination.styles'

export type PaginationProps = {
  page: number
  pages: number
  count: number
  countLabel: string
  onPrevious: () => void
  onNext: () => void
}

// Previous / summary / Next cluster for server-driven listing pages.
export function Pagination({
  page,
  pages,
  count,
  countLabel,
  onPrevious,
  onNext,
}: PaginationProps) {
  return (
    <StyledNavigation>
      <Button variant="secondary" size="sm" type="button" disabled={page <= 1} onClick={onPrevious}>
        Previous
      </Button>
      <StyledSummary>
        Page {page} of {pages} ({count} {countLabel})
      </StyledSummary>
      <Button variant="secondary" size="sm" type="button" disabled={page >= pages} onClick={onNext}>
        Next
      </Button>
    </StyledNavigation>
  )
}
