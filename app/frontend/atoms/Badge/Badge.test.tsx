import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Badge } from './Badge'

describe('Badge', () => {
  it('defaults to neutral', () => {
    render(<Badge>Draft</Badge>)
    expect(screen.getByText('Draft')).toHaveClass('bg-line-soft')
  })

  it('maps role and import statuses to variants', () => {
    render(<Badge variant="admin">admin</Badge>)
    expect(screen.getByText('admin')).toHaveClass('bg-brand-soft')

    render(<Badge variant="failed">failed</Badge>)
    expect(screen.getByText('failed')).toHaveClass('bg-danger-soft')
  })

  it('keeps data attributes for tests/selectors', () => {
    render(
      <Badge variant="processing" data-status="processing">
        Processing
      </Badge>,
    )
    expect(screen.getByText('Processing')).toHaveAttribute('data-status', 'processing')
  })

  it('merges consumer className', () => {
    render(<Badge className="uppercase">X</Badge>)
    expect(screen.getByText('X')).toHaveClass('uppercase')
  })
})
