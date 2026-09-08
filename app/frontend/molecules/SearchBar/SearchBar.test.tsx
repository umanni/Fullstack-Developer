import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useState } from 'react'
import { describe, expect, it, vi } from 'vitest'

import { SearchBar } from './SearchBar'

describe('SearchBar', () => {
  it('drives onChange and submits', async () => {
    const user = userEvent.setup()
    const onChange = vi.fn()
    const onSubmit = vi.fn()

    function Fixture() {
      const [value, setValue] = useState('')
      return (
        <SearchBar
          value={value}
          onChange={(next) => {
            onChange(next)
            setValue(next)
          }}
          onSubmit={onSubmit}
          placeholder="Search people"
        />
      )
    }

    render(<Fixture />)
    const input = screen.getByRole('searchbox')
    await user.type(input, 'ada')
    expect(onChange).toHaveBeenLastCalledWith('ada')
    await user.click(screen.getByRole('button', { name: /search/i }))
    expect(onSubmit).toHaveBeenCalledTimes(1)
  })
})
