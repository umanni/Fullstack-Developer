import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { ProgressBar } from './ProgressBar'

describe('ProgressBar', () => {
  it('exposes progress to assistive tech', () => {
    render(<ProgressBar percent={42} />)
    const bar = screen.getByRole('progressbar')
    expect(bar).toHaveAttribute('aria-valuenow', '42')
    expect(bar.getAttribute('class')).toContain('bg-line-soft')
  })

  it('clamps percent to 0..100', () => {
    const { container } = render(<ProgressBar percent={150} />)
    const fill = container.querySelector('[style*="--progress"]')
    expect(fill?.getAttribute('style')).toContain('100%')
  })

  it('applies terminal variants', () => {
    const { container } = render(<ProgressBar percent={100} variant="failed" />)
    expect(container.querySelector('span span')).toHaveClass('bg-danger')
  })
})
