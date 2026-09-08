import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Icon } from './Icon'

describe('Icon', () => {
  it('renders a decorative inline svg', () => {
    render(<Icon name="search" data-testid="icon" />)
    const svg = screen.getByTestId('icon')
    expect(svg.tagName).toBe('svg')
    expect(svg).toHaveAttribute('aria-hidden', 'true')
    expect(svg).toHaveClass('size-5')
  })

  it('applies size variant', () => {
    render(<Icon name="plus" size="sm" data-testid="icon" />)
    expect(screen.getByTestId('icon')).toHaveClass('size-4')
  })
})
