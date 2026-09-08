import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { Button } from './Button'

describe('Button', () => {
  it('renders children with primary + md styles by default', () => {
    render(<Button>Save</Button>)
    const button = screen.getByRole('button', { name: 'Save' })
    expect(button).toBeInTheDocument()
    expect(button).toHaveClass('bg-brand', 'py-2')
  })

  it('applies the danger variant and sm size', () => {
    render(
      <Button variant="danger" size="sm">
        Delete
      </Button>,
    )
    const button = screen.getByRole('button', { name: 'Delete' })
    expect(button).toHaveClass('bg-danger', 'px-3', 'py-1.5')
  })

  it('merges consumer className last (Tailwind-aware)', () => {
    render(<Button className="bg-red-500">Custom</Button>)
    expect(screen.getByRole('button', { name: 'Custom' })).toHaveClass('bg-red-500')
    expect(screen.getByRole('button', { name: 'Custom' })).not.toHaveClass('bg-brand')
  })

  it('renders polymorphic `as` tag', () => {
    render(
      <Button as="span" data-testid="poly">
        Span
      </Button>,
    )
    expect(screen.getByTestId('poly').tagName).toBe('SPAN')
  })

  it('respects onClick', async () => {
    const user = userEvent.setup()
    const onClick = vi.fn()
    render(<Button onClick={onClick}>Go</Button>)
    await user.click(screen.getByRole('button', { name: 'Go' }))
    expect(onClick).toHaveBeenCalledTimes(1)
  })
})
