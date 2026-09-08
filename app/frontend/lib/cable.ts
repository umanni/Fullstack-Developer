import { createConsumer } from '@rails/actioncable'
import { useEffect, useRef } from 'react'

// WebSocket is an external boundary: the only way realtime enters the app is
// through store.ingest (handlers call an action — no emitters/bus inside).
const consumer = createConsumer()

export type CableParams = Record<string, string | number | boolean | null>

// Subscribes once per (channel, params) and unsubscribes on unmount/change.
// The received handler is kept in a ref so identity churn never resubscribes.
export function useChannel<TPayload = unknown>(
  channelName: string,
  params: CableParams,
  onReceived: (payload: TPayload) => void,
) {
  const handlerRef = useRef(onReceived)

  // Keep the ref current without re-subscribing the cable subscription.
  useEffect(() => {
    handlerRef.current = onReceived
  })

  const identifier = JSON.stringify({ channel: channelName, ...params })

  useEffect(() => {
    const subscription = consumer.subscriptions.create(JSON.parse(identifier), {
      received: (payload) => handlerRef.current(payload as TPayload),
    })

    return () => {
      subscription.unsubscribe()
    }
  }, [identifier])
}
