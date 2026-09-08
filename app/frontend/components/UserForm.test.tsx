import { fireEvent, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { ReactNode } from 'react'

import { UserForm } from '@/components/UserForm'
import type { User } from '@/types'
import { useForm } from '@inertiajs/react'

jest.mock(
  '@inertiajs/react',
  () => ({
    Link: ({ children, href }: { children: ReactNode; href: string }) => (
      <a href={href}>{children}</a>
    ),
    useForm: jest.fn(),
  }),
  { virtual: true },
)

const mockedUseForm = jest.mocked(useForm)
const form = {
  data: {
    full_name: 'Grace Hopper',
    email: 'grace@example.com',
    role: 'user',
    password: '',
    password_confirmation: '',
    avatar_image: null,
    remove_avatar: false,
  },
  errors: {},
  processing: false,
  setData: jest.fn(),
  transform: jest.fn(),
  post: jest.fn(),
  patch: jest.fn(),
  reset: jest.fn(),
}

const existingUser: User = {
  id: 3,
  full_name: 'Grace Hopper',
  email: 'grace@example.com',
  role: 'admin',
  avatar_url: '/avatar.png',
  created_at: '2026-01-01T00:00:00Z',
}

beforeEach(() => {
  jest.clearAllMocks()
  mockedUseForm.mockReturnValue(form as never)
})

test('creates a user with role and required password fields', async () => {
  const { container } = render(
    <UserForm
      action="/admin/users"
      allowRole
      cancelHref="/admin/users"
      submitLabel="Create user"
    />,
  )

  expect(screen.getByRole('combobox')).toBeVisible()
  expect(container.querySelector('input[type="password"]')).toBeRequired()
  await userEvent.selectOptions(screen.getByRole('combobox'), 'admin')
  const formElement = container.querySelector('form')
  expect(formElement).not.toBeNull()
  if (!formElement) throw new Error('Expected a user form')
  fireEvent.submit(formElement)

  expect(form.transform).toHaveBeenCalled()
  expect(form.post).toHaveBeenCalledWith(
    '/admin/users',
    expect.objectContaining({ forceFormData: true }),
  )
})

test('edits an existing user and offers avatar removal', async () => {
  render(
    <UserForm
      action="/profile"
      cancelHref="/profile"
      submitLabel="Save changes"
      user={existingUser}
    />,
  )

  expect(screen.queryByRole('combobox')).not.toBeInTheDocument()
  expect(
    screen.getByRole('img', { name: "Grace Hopper's avatar" }),
  ).toBeVisible()
  await userEvent.click(
    screen.getByRole('checkbox', { name: 'Remove current avatar' }),
  )
  expect(form.setData).toHaveBeenCalledWith('remove_avatar', true)

  await userEvent.click(screen.getByRole('button', { name: 'Save changes' }))
  expect(form.patch).toHaveBeenCalledWith('/profile', expect.any(Object))
})

test('passes changed text and file values to Inertia form state', async () => {
  const { container } = render(
    <UserForm
      action="/profile"
      cancelHref="/profile"
      submitLabel="Save changes"
      user={existingUser}
    />,
  )

  await userEvent.type(
    screen.getByLabelText('Full name', { selector: 'input' }),
    ' X',
  )
  await userEvent.type(screen.getByLabelText('Email address'), 'x')
  const passwordInputs = container.querySelectorAll('input[type="password"]')
  await userEvent.type(passwordInputs[0], 'StrongPassword!123')
  await userEvent.type(passwordInputs[1], 'StrongPassword!123')
  const file = new File(['image'], 'avatar.png', { type: 'image/png' })
  const fileInput =
    container.querySelector<HTMLInputElement>('input[type="file"]')
  expect(fileInput).not.toBeNull()
  if (!fileInput) throw new Error('Expected an avatar input')
  await userEvent.upload(fileInput, file)

  expect(form.setData).toHaveBeenCalledWith(
    'full_name',
    expect.stringContaining('X'),
  )
  expect(form.setData).toHaveBeenCalledWith('avatar_image', file)
})
