import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { RoleBadge } from './RoleBadge'

describe('RoleBadge', () => {
  it('maps admin to the brand variant', () => {
    render(<RoleBadge role="admin" />)
    expect(screen.getByText('admin')).toHaveClass('bg-brand-soft')
  })

  it('maps user to the neutral variant', () => {
    render(<RoleBadge role="user" />)
    expect(screen.getByText('user')).toHaveClass('bg-line-soft')
  })
})
