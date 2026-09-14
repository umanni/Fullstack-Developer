import { useMemo } from 'react'
import { useHydrated } from '@/hooks/useHydrated'

// The SSR server can't know the visitor's locale or time zone. The first render (on the server
// and during hydration) uses this fixed pair so both sides produce the same text; the browser's
// own locale and time zone take over in the render after hydration.
const SERVER_LOCALE = 'en-US'
const SERVER_TIME_ZONE = 'UTC'

const dateTimeFormats = new Map<string, Intl.DateTimeFormat>()

function dateTimeFormat(options: Intl.DateTimeFormatOptions, hydrated: boolean) {
  const key = `${hydrated}:${JSON.stringify(options)}`
  let format = dateTimeFormats.get(key)

  if (!format) {
    format = hydrated
      ? new Intl.DateTimeFormat(undefined, options)
      : new Intl.DateTimeFormat(SERVER_LOCALE, { ...options, timeZone: SERVER_TIME_ZONE })
    dateTimeFormats.set(key, format)
  }

  return format
}

/** Number and date formatting that is safe to server-render. */
export function useLocaleFormat() {
  const hydrated = useHydrated()

  return useMemo(
    () => ({
      number: (value: number) => value.toLocaleString(hydrated ? undefined : SERVER_LOCALE),
      dateTime: (iso: string, options: Intl.DateTimeFormatOptions) =>
        dateTimeFormat(options, hydrated).format(new Date(iso)),
    }),
    [hydrated],
  )
}
