import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { FormErrorAlert } from './FormErrorAlert'

describe('FormErrorAlert', () => {
  it('renders nothing without errors', () => {
    const { container } = render(<FormErrorAlert errors={{}} />)
    expect(container).toBeEmptyDOMElement()
  })

  it('shows the base error as a danger alert', () => {
    render(<FormErrorAlert errors={{ base: ['Credentials are invalid.'] }} />)
    const alert = screen.getByRole('alert')
    expect(alert).toHaveTextContent('Credentials are invalid.')
  })

  it('falls back to the form key', () => {
    render(<FormErrorAlert errors={{ form: ['File rejected.'] }} />)
    expect(screen.getByRole('alert')).toHaveTextContent('File rejected.')
  })
})
