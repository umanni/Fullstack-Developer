import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Heading } from './Heading'

describe('Heading', () => {
  it('renders lg as h1', () => {
    render(<Heading>Page title</Heading>)
    expect(screen.getByRole('heading', { level: 1, name: 'Page title' })).toBeInTheDocument()
  })

  it('maps sizes to semantic tags', () => {
    render(<Heading size="md">Section</Heading>)
    expect(screen.getByRole('heading', { level: 2, name: 'Section' })).toHaveClass('text-xl')
  })
})
