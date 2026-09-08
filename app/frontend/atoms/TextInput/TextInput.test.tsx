import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { TextInput } from './TextInput'

describe('TextInput', () => {
  it('renders a labelled input with normal tone by default', () => {
    render(<TextInput aria-label="Name" />)
    const input = screen.getByRole('textbox', { name: 'Name' })
    expect(input).toHaveClass('border-line')
    expect(input).not.toHaveAttribute('aria-invalid')
  })

  it('marks invalid inputs for assistive tech', () => {
    render(<TextInput aria-label="Name" tone="invalid" />)
    const input = screen.getByRole('textbox', { name: 'Name' })
    expect(input).toHaveClass('border-danger')
    expect(input).toHaveAttribute('aria-invalid', 'true')
  })

  it('keeps native attributes and merges className', () => {
    render(<TextInput aria-label="Password" type="password" className="max-w-xs" />)
    expect(screen.getByLabelText('Password')).toHaveAttribute('type', 'password')
    expect(screen.getByLabelText('Password')).toHaveClass('max-w-xs')
  })

  it('drives onChange and ref', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()
    const ref = vi.fn()
    render(
      <TextInput
        aria-label="Email"
        name="email_address"
        onChange={(event) => onChange(event.target.value)}
        ref={ref}
      />,
    )
    await user.type(screen.getByLabelText('Email'), 'a@b.com')
    expect(onChange).toHaveBeenLastCalledWith('a@b.com')
    expect(ref).toHaveBeenCalledTimes(1)
    expect(ref.mock.calls[0][0]).toBeInstanceOf(HTMLInputElement)
  })
})
