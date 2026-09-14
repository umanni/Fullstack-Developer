import { useEffect, useRef, useState } from 'react'
import { useLocaleFormat } from '@/hooks/useLocaleFormat'

const DURATION = 400

const prefersReducedMotion = () =>
  window.matchMedia?.('(prefers-reduced-motion: reduce)').matches ?? false

export default function StatCard({ label, value }: { label: string; value: number }) {
  const [shown, setShown] = useState(value)
  const from = useRef(value)
  const format = useLocaleFormat()

  useEffect(() => {
    if (from.current === value) return

    if (prefersReducedMotion()) {
      from.current = value
      setShown(value)
      return
    }

    const start = performance.now()
    const origin = from.current
    let frame: number

    const tick = (now: number) => {
      const progress = Math.min((now - start) / DURATION, 1)
      const eased = 1 - (1 - progress) ** 3
      const current = Math.round(origin + (value - origin) * eased)

      // Broadcasts land every few hundred ms, so a new value often arrives
      // mid-flight. Park the on-screen count here and the next run picks it
      // up as its origin instead of snapping back to the last settled one.
      from.current = current
      setShown(current)

      if (progress < 1) frame = requestAnimationFrame(tick)
      else from.current = value
    }

    frame = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(frame)
  }, [value])

  return (
    <div className="rounded-lg border border-slate-200 bg-white p-6">
      <dt className="text-xs font-medium uppercase tracking-wide text-slate-500">{label}</dt>
      <dd className="mt-2 text-4xl font-semibold tabular-nums" aria-hidden>
        {format.number(shown)}
      </dd>
      {/* Announce the settled count once, not once per frame. */}
      <span className="sr-only" aria-live="polite">
        {label}: {format.number(value)}
      </span>
    </div>
  )
}
