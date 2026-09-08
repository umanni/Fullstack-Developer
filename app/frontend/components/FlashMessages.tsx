import { usePage } from '@inertiajs/react'
import { useState } from 'react'

import { Icon } from '@/components/Icon'

export function FlashMessages() {
  const { flash } = usePage()
  const [visible, setVisible] = useState(true)
  const message = flash.notice ?? flash.alert

  if (!message || !visible) return null

  const isAlert = Boolean(flash.alert)

  return (
    <div
      className="pointer-events-none fixed inset-x-4 top-4 z-50 flex justify-center sm:justify-end"
      role={isAlert ? 'alert' : 'status'}
    >
      <div
        className={`pointer-events-auto flex max-w-md items-start gap-3 rounded-2xl border bg-white px-4 py-3 shadow-xl ${
          isAlert
            ? 'border-rose-200 text-rose-800'
            : 'border-emerald-200 text-emerald-800'
        }`}
      >
        <Icon
          className="mt-0.5 size-5 shrink-0"
          name={isAlert ? 'x' : 'check'}
        />
        <p className="text-sm font-medium">{message}</p>
        <button
          aria-label="Dismiss notification"
          className="ml-1 rounded p-0.5 hover:bg-slate-100"
          onClick={() => setVisible(false)}
          type="button"
        >
          <Icon className="size-4" name="x" />
        </button>
      </div>
    </div>
  )
}
