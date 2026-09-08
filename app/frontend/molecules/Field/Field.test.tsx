import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import { TextInput } from '@/atoms/TextInput/TextInput'

import { Field } from './Field'

describe('Field', () => {
  it('wires label to the control', () => {
    render(
      <Field label="Email address" htmlFor="email">
        <TextInput id="email" />
      </Field>,
    )
    expect(screen.getByLabelText('Email address')).toBeInTheDocument()
  })

  it('shows the hint when no error', () => {
    render(
      <Field label="Avatar" hint="Provide a URL.">
        <TextInput aria-label="Avatar input" />
      </Field>,
    )
    expect(screen.getByText('Provide a URL.')).toBeInTheDocument()
  })

  it('error wins over hint and is announced', () => {
    render(
      <Field label="Avatar" hint="Nope" error="Invalid URL.">
        <TextInput aria-label="Avatar input" />
      </Field>,
    )
    expect(screen.getByRole('alert')).toHaveTextContent('Invalid URL.')
    expect(screen.queryByText('Nope')).not.toBeInTheDocument()
  })
})
