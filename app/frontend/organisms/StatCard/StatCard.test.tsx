import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { StatCard } from './StatCard'

describe('StatCard', () => {
  it('renders the label and count', () => {
    render(<StatCard label="Total users" value={42} />)
    expect(screen.getByText('Total users')).toBeInTheDocument()
    expect(screen.getByText('42')).toBeInTheDocument()
  })
})
