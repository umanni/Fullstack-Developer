import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Alert } from './Alert'

describe('Alert', () => {
  it('defaults to info status', () => {
    render(<Alert>Heads up</Alert>)
    const alert = screen.getByRole('status')
    expect(alert).toHaveTextContent('Heads up')
    expect(alert).toHaveClass('bg-brand-soft')
  })

  it('uses role=alert for danger and maps the icon', () => {
    render(
      <Alert variant="danger" title="Failed">
        Something broke
      </Alert>,
    )
    const alert = screen.getByRole('alert')
    expect(alert).toHaveTextContent('Failed')
    expect(alert).toHaveTextContent('Something broke')
    expect(alert).toHaveClass('bg-danger-soft')
    expect(alert.querySelector('svg')).not.toBeNull()
  })
})
