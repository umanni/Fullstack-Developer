import { useEffect, useState } from 'react'

import { cable } from '@/lib/cable'
import type { UserStatistics } from '@/types'

export function useDashboardStatistics(initialStatistics: UserStatistics) {
  const [statistics, setStatistics] = useState(initialStatistics)

  useEffect(() => {
    const subscription = cable().subscriptions.create(
      { channel: 'AdminDashboardChannel' },
      { received: (data: UserStatistics) => setStatistics(data) },
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  return statistics
}
