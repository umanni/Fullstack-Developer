import { act, renderHook } from '@testing-library/react'

import { useDashboardStatistics } from '@/hooks/useDashboardStatistics'
import { useImportProgress } from '@/hooks/useImportProgress'
import { cable } from '@/lib/cable'
import type { UserImport, UserStatistics } from '@/types'

jest.mock('@/lib/cable', () => ({ cable: jest.fn() }))

const mockedCable = jest.mocked(cable)
const unsubscribe = jest.fn()
let received: (payload: never) => void = () => undefined

type SubscriptionCallbacks = { received: (payload: never) => void }

beforeEach(() => {
  jest.clearAllMocks()
  mockedCable.mockReturnValue({
    subscriptions: {
      create: jest.fn(
        (_identifier: unknown, callbacks: SubscriptionCallbacks) => {
          received = callbacks.received
          return { unsubscribe }
        },
      ),
    },
  } as never)
})

test('streams dashboard statistics and unsubscribes on cleanup', () => {
  const initial: UserStatistics = {
    total: 2,
    by_role: { admin: 1, user: 1 },
    generated_at: 'before',
  }
  const updated: UserStatistics = {
    total: 3,
    by_role: { admin: 1, user: 2 },
    generated_at: 'after',
  }
  const { result, unmount } = renderHook(() => useDashboardStatistics(initial))

  act(() => received(updated as never))
  expect(result.current).toEqual(updated)
  unmount()
  expect(unsubscribe).toHaveBeenCalled()
})

test('merges import progress while preserving detailed errors', () => {
  const initial: UserImport = {
    id: 4,
    status: 'processing',
    file_name: 'users.csv',
    total_rows: 2,
    processed_rows: 0,
    successful_rows: 0,
    failed_rows: 0,
    progress_percentage: 0,
    failure_message: null,
    uploaded_by: 'Admin',
    created_at: 'now',
    started_at: 'now',
    finished_at: null,
    row_errors: [
      { row_number: 2, email: 'bad@example.com', message: 'Invalid' },
    ],
  }
  const { result, unmount } = renderHook(() => useImportProgress(initial))

  act(() =>
    received({ status: 'completed', progress_percentage: 100 } as never),
  )
  expect(result.current.status).toBe('completed')
  expect(result.current.row_errors).toHaveLength(1)
  unmount()
  expect(unsubscribe).toHaveBeenCalled()
})
