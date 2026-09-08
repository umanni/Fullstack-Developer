import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { EmptyState } from './EmptyState'

describe('EmptyState', () => {
  it('renders title, description and action', () => {
    render(
      <EmptyState
        icon="users"
        title="No users"
        description="Nothing to see yet."
        action={<button type="button">Create</button>}
      />,
    )
    expect(screen.getByText('No users')).toBeInTheDocument()
    expect(screen.getByText('Nothing to see yet.')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Create' })).toBeInTheDocument()
  })
})
