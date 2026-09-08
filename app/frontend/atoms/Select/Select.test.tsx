import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'

import { Select } from './Select'

describe('Select', () => {
  const options = (
    <>
      <option value="user">User</option>
      <option value="admin">Admin</option>
    </>
  )

  it('renders options and remembers the selection', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()
    render(
      <Select
        aria-label="Role"
        name="role"
        defaultValue="user"
        onChange={(e) => onChange(e.target.value)}
      >
        {options}
      </Select>,
    )
    const select = screen.getByRole('combobox', { name: 'Role' })
    await user.selectOptions(select, 'admin')
    expect(onChange).toHaveBeenCalledWith('admin')
    expect(select).toHaveValue('admin')
  })

  it('marks invalid tone', () => {
    render(
      <Select aria-label="Role" tone="invalid" defaultValue="user">
        {options}
      </Select>,
    )
    expect(screen.getByRole('combobox', { name: 'Role' })).toHaveClass('border-danger')
  })
})
