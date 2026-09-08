import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { Avatar } from './Avatar'
import { avatarFallbackPalette } from './Avatar.styles'

describe('Avatar', () => {
  it('renders an image when src is provided', () => {
    render(<Avatar src="https://example.test/a.png" alt="Ada" />)
    const img = screen.getByRole('img', { name: 'Ada' })
    expect(img).toHaveAttribute('src', 'https://example.test/a.png')
    expect(img).toHaveClass('h-10')
  })

  it('renders the bold first-letter fallback without src', () => {
    render(<Avatar src={null} alt="Grace Hopper" />)
    const fallback = screen.getByRole('img', { name: 'Grace Hopper' })
    expect(fallback).toHaveTextContent('G')
    expect(fallback).not.toHaveTextContent('Grace')
    expect(fallback).toHaveClass('font-bold', 'uppercase')
  })

  it('applies a palette background tone to the fallback', () => {
    render(<Avatar src={null} alt="Grace Hopper" />)
    const fallback = screen.getByRole('img', { name: 'Grace Hopper' })
    const classes = fallback.className
    const matched = avatarFallbackPalette.some(
      (tone) => classes.includes(tone.bg) && classes.includes(tone.text),
    )
    expect(matched).toBe(true)
  })

  it('supports lg size', () => {
    render(<Avatar src={null} alt="x" size="lg" />)
    expect(screen.getByRole('img')).toHaveClass('h-20')
  })
})
