import { createConsumer } from '@rails/actioncable'

import { cable, disconnectCable } from '@/lib/cable'
import { classNames } from '@/lib/class-names'
import { formatDate, initials, pluralize } from '@/lib/formatters'
import { routes } from '@/lib/routes'

jest.mock('@rails/actioncable', () => ({ createConsumer: jest.fn() }))

const mockedCreateConsumer = jest.mocked(createConsumer)
const disconnect = jest.fn()

beforeEach(() => {
  disconnectCable()
  jest.clearAllMocks()
  mockedCreateConsumer.mockReturnValue({ disconnect } as never)
})

test('joins truthy class names', () => {
  expect(classNames('one', false, null, undefined, 'two')).toBe('one two')
})

test('formats names, counts, and dates', () => {
  expect(initials('  Ada   Lovelace Byron ')).toBe('AL')
  expect(pluralize(1, 'person', 'people')).toBe('1 person')
  expect(pluralize(2, 'person', 'people')).toBe('2 people')
  expect(formatDate(null)).toBe('Not available')
  expect(formatDate('2026-09-07T12:00:00Z')).toMatch(/2026/)
})

test('builds resource routes', () => {
  expect(routes.editAdminUser(7)).toBe('/admin/users/7/edit')
  expect(routes.adminUser(7)).toBe('/admin/users/7')
  expect(routes.toggleAdminUserRole(7)).toBe('/admin/users/7/toggle_role')
  expect(routes.adminImport(4)).toBe('/admin/user_imports/4')
})

test('reuses and disconnects the Action Cable consumer', () => {
  const first = cable()
  const second = cable()
  expect(first).toBe(second)
  expect(mockedCreateConsumer).toHaveBeenCalledTimes(1)

  disconnectCable()
  expect(disconnect).toHaveBeenCalled()
  cable()
  expect(mockedCreateConsumer).toHaveBeenCalledTimes(2)
})
