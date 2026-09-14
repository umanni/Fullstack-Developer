import { useSyncExternalStore } from 'react'

const subscribe = () => () => {}

/**
 * false on the SSR server and while React hydrates the HTML it sent, true from the render
 * right after. A component can render exactly what the server did, then switch to values
 * only the browser knows (locale, time zone) without a hydration mismatch.
 */
export const useHydrated = () =>
  useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  )
