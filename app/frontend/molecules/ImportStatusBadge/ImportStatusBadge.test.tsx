import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { ImportStatusBadge } from './ImportStatusBadge'

describe('ImportStatusBadge', () => {
  it.each(['pending', 'processing', 'completed', 'failed'] as const)(
    'maps %s to a human label + variant',
    (status) => {
      const { container } = render(<ImportStatusBadge status={status} />)
      const badge = container.querySelector('[data-status]')
      expect(badge).toHaveAttribute('data-status', status)
      expect(screen.getByText(status.charAt(0).toUpperCase() + status.slice(1))).toBeInTheDocument()
    },
  )
})
