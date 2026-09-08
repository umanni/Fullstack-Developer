import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { DetailRow } from './DetailRow'

describe('DetailRow', () => {
  it('renders label and value', () => {
    render(<DetailRow label="Status">Ready</DetailRow>)
    expect(screen.getByText('Status')).toBeInTheDocument()
    expect(screen.getByText('Ready')).toBeInTheDocument()
  })
})
