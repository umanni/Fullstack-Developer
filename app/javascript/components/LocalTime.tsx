import { useLocaleFormat } from '@/hooks/useLocaleFormat'

type Props = {
  /** ISO 8601 timestamp. */
  dateTime: string
  options: Intl.DateTimeFormatOptions
}

/** A <time> shown in the visitor's locale and time zone once the page has hydrated. */
export default function LocalTime({ dateTime, options }: Props) {
  const format = useLocaleFormat()

  return <time dateTime={dateTime}>{format.dateTime(dateTime, options)}</time>
}
