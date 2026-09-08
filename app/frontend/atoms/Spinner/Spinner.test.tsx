import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Spinner } from './Spinner'

describe('Spinner', () => {
  it('announces a status with sr-only text', () => {
    render(<Spinner />)
    expect(screen.getByRole('status')).toBeInTheDocument()
    expect(screen.getByText('Loading…')).toHaveClass('sr-only')
  })

  it('allows a custom label', () => {
    render(<Spinner label="Saving…" />)
    expect(screen.getByText('Saving…')).toBeInTheDocument()
  })
})
