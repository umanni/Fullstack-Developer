import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { FormEvent } from 'react'
import { describe, expect, it, vi } from 'vitest'

import { Form } from './Form'

describe('Form', () => {
  it('submits on enter and passes the submit event', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn((event: FormEvent<HTMLFormElement>) => {
      event.preventDefault()
    })
    render(
      <Form onSubmit={onSubmit}>
        <input name="q" aria-label="Query" />
      </Form>,
    )
    await user.type(screen.getByLabelText('Query'), 'ada{Enter}')
    expect(onSubmit).toHaveBeenCalled()
  })
})
