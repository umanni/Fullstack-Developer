import { useEffect, useState } from 'react'

import { cable } from '@/lib/cable'
import type { UserImport } from '@/types'

export function useImportProgress(initialImport: UserImport) {
  const [userImport, setUserImport] = useState(initialImport)

  useEffect(() => {
    const subscription = cable().subscriptions.create(
      { channel: 'ImportProgressChannel', id: initialImport.id },
      {
        received: (data: UserImport) =>
          setUserImport((current) => ({ ...current, ...data })),
      },
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [initialImport.id])

  return userImport
}
