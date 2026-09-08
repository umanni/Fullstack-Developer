import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Label } from './Label'

describe('Label', () => {
  it('renders with htmlFor', () => {
    render(<Label htmlFor="email">Email address</Label>)
    const label = screen.getByText('Email address')
    expect(label).toHaveAttribute('for', 'email')
    expect(label).toHaveClass('text-ink-soft')
  })
})
