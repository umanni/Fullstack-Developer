import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import type { ReactNode } from 'react'

import { Avatar } from '@/components/Avatar'
import { Badge } from '@/components/Badge'
import { Button, ButtonLink, buttonClasses } from '@/components/Button'
import { EmptyState } from '@/components/EmptyState'
import { FlashMessages } from '@/components/FlashMessages'
import { Field, Input, Select } from '@/components/FormField'
import { Icon } from '@/components/Icon'
import { ImportSummary } from '@/components/ImportSummary'
import { Logo } from '@/components/Logo'
import { PageHeader } from '@/components/PageHeader'
import { Pagination } from '@/components/Pagination'
import { ProgressBar } from '@/components/ProgressBar'
import type { UserImport } from '@/types'
import { usePage } from '@inertiajs/react'

jest.mock(
  '@inertiajs/react',
  () => ({
    Link: ({ children, href }: { children: ReactNode; href: string }) => (
      <a href={href}>{children}</a>
    ),
    usePage: jest.fn(),
  }),
  { virtual: true },
)

const mockedUsePage = jest.mocked(usePage)

const userImport: UserImport = {
  id: 7,
  status: 'processing',
  file_name: 'people.csv',
  total_rows: 4,
  processed_rows: 2,
  successful_rows: 2,
  failed_rows: 0,
  progress_percentage: 50,
  failure_message: null,
  uploaded_by: 'Ada Admin',
  created_at: '2026-09-07T12:00:00Z',
  started_at: '2026-09-07T12:01:00Z',
  finished_at: null,
  row_errors: [],
}

describe('shared UI components', () => {
  test('renders avatar images and accessible initials fallbacks', () => {
    const { rerender } = render(
      <Avatar name="Ada Lovelace" size="lg" src={null} />,
    )
    expect(screen.getByLabelText("Ada Lovelace's initials")).toHaveTextContent(
      'AL',
    )

    rerender(<Avatar name="Ada Lovelace" size="sm" src="/avatar.png" />)
    expect(
      screen.getByRole('img', { name: "Ada Lovelace's avatar" }),
    ).toHaveAttribute('src', '/avatar.png')
  })

  test('renders role and import status badges', () => {
    const { rerender } = render(<Badge value="admin" />)
    expect(screen.getByText('Admin')).toBeVisible()

    rerender(<Badge value="completed_with_errors" />)
    expect(screen.getByText('Completed with errors')).toBeVisible()
  })

  test('builds buttons and links for every visual intent', () => {
    render(
      <>
        <Button variant="danger">Delete</Button>
        <ButtonLink href="/users" size="sm" variant="secondary">
          Users
        </ButtonLink>
      </>,
    )

    expect(screen.getByRole('button', { name: 'Delete' })).toHaveAttribute(
      'type',
      'button',
    )
    expect(screen.getByRole('link', { name: 'Users' })).toHaveAttribute(
      'href',
      '/users',
    )
    expect(buttonClasses({ variant: 'ghost', className: 'custom' })).toContain(
      'custom',
    )
    expect(buttonClasses()).toContain('bg-brand-600')
  })

  test('renders fields, errors, inputs, and selects', () => {
    render(
      <Field error={['Required', 'Invalid']} hint="Helpful" label="Email">
        <Input aria-label="Email input" />
        <Select aria-label="Role">
          <option>User</option>
        </Select>
      </Field>,
    )

    expect(screen.getByText('Required, Invalid')).toBeVisible()
    expect(screen.getByText('Helpful')).toBeVisible()
    expect(screen.getByLabelText('Email input')).toBeInstanceOf(
      HTMLInputElement,
    )
    expect(screen.getByLabelText('Role')).toBeInstanceOf(HTMLSelectElement)
  })

  test('renders supporting presentational components', () => {
    render(
      <>
        <Logo />
        <Icon name="users" />
        <PageHeader
          actions={<span>Action</span>}
          description="Description"
          eyebrow="Admin"
          title="People"
        />
        <EmptyState
          action={<button type="button">Add</button>}
          description="Nothing yet"
          icon="user"
          title="Empty"
        />
      </>,
    )

    expect(screen.getAllByRole('link')[0]).toHaveTextContent('PeopleHub')
    expect(screen.getByRole('heading', { name: 'People' })).toBeVisible()
    expect(screen.getByRole('heading', { name: 'Empty' })).toBeVisible()
    expect(screen.getByRole('button', { name: 'Add' })).toBeEnabled()
  })

  test('exposes bounded, accessible progress', () => {
    const { rerender } = render(<ProgressBar label="Rows" value={140} />)
    expect(screen.getByRole('progressbar')).toHaveAttribute(
      'aria-valuenow',
      '100',
    )

    rerender(<ProgressBar value={-5} />)
    expect(screen.getByRole('progressbar')).toHaveAttribute(
      'aria-valuenow',
      '0',
    )
  })

  test('summarizes imports in default and detailed modes', () => {
    const { rerender } = render(<ImportSummary item={userImport} />)
    expect(screen.getByText('people.csv')).toBeVisible()
    expect(screen.queryByText('Total')).not.toBeInTheDocument()

    rerender(<ImportSummary detailed item={userImport} />)
    expect(screen.getByText('Total')).toBeVisible()
    expect(screen.getByText('Created')).toBeVisible()
  })

  test('renders available pagination directions and hides a single page', () => {
    const hrefFor = (page: number) => `/users?page=${page}`
    const { rerender } = render(
      <Pagination
        hrefFor={hrefFor}
        pagination={{
          page: 2,
          pages: 3,
          count: 30,
          limit: 10,
          previous: 1,
          next: 3,
        }}
      />,
    )
    expect(screen.getByRole('link', { name: /Previous/ })).toHaveAttribute(
      'href',
      '/users?page=1',
    )
    expect(screen.getByRole('link', { name: /Next/ })).toHaveAttribute(
      'href',
      '/users?page=3',
    )

    rerender(
      <Pagination
        hrefFor={hrefFor}
        pagination={{
          page: 1,
          pages: 1,
          count: 2,
          limit: 10,
          previous: null,
          next: null,
        }}
      />,
    )
    expect(screen.queryByRole('navigation')).not.toBeInTheDocument()
  })

  test('allows flash notifications to be dismissed', async () => {
    mockedUsePage.mockReturnValue({ flash: { notice: 'Saved' } } as ReturnType<
      typeof usePage
    >)
    render(<FlashMessages />)

    expect(screen.getByRole('status')).toHaveTextContent('Saved')
    await userEvent.click(
      screen.getByRole('button', { name: 'Dismiss notification' }),
    )
    expect(screen.queryByRole('status')).not.toBeInTheDocument()
  })

  test('renders alert flashes and nothing when flash is empty', () => {
    mockedUsePage.mockReturnValue({ flash: { alert: 'Denied' } } as ReturnType<
      typeof usePage
    >)
    const { rerender } = render(<FlashMessages />)
    expect(screen.getByRole('alert')).toHaveTextContent('Denied')

    mockedUsePage.mockReturnValue({ flash: {} } as ReturnType<typeof usePage>)
    rerender(<FlashMessages />)
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
