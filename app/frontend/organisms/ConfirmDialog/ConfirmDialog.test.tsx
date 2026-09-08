import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { ConfirmDialog } from './ConfirmDialog'

const base = {
  title: 'Delete user',
  description: 'This cannot be undone.',
  onConfirm: vi.fn(),
  onCancel: vi.fn(),
}

describe('ConfirmDialog', () => {
  it('renders nothing when closed', () => {
    const { container } = render(<ConfirmDialog open={false} {...base} />)
    expect(container).toBeEmptyDOMElement()
  })

  it('renders a modal dialog with actions', () => {
    render(<ConfirmDialog open {...base} />)
    const dialog = screen.getByRole('dialog', { name: 'Delete user' })
    expect(dialog).toHaveAttribute('aria-modal', 'true')
    expect(screen.getAllByRole('button', { name: 'Delete' }).length).toBeGreaterThan(0)
  })

  it('confirms on the danger button', async () => {
    const user = userEvent.setup()
    render(<ConfirmDialog open {...base} />)
    await user.click(screen.getByRole('button', { name: 'Delete' }))
    expect(base.onConfirm).toHaveBeenCalledTimes(1)
  })

  it('cancels on Escape', async () => {
    const user = userEvent.setup()
    render(<ConfirmDialog open {...base} />)
    await user.keyboard('{Escape}')
    expect(base.onCancel).toHaveBeenCalledTimes(1)
  })
})
