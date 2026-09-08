import type {
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
} from 'react'

import type { ErrorValue } from '@/types'

const inputClasses =
  'block min-h-11 w-full rounded-xl border-slate-300 bg-white px-3.5 text-sm text-slate-950 shadow-sm placeholder:text-slate-400 focus:border-brand-500 focus:ring-brand-500 disabled:cursor-not-allowed disabled:bg-slate-100'

export function Field({
  label,
  hint,
  error,
  children,
}: {
  label: string
  hint?: string
  error?: ErrorValue
  children: ReactNode
}) {
  const message = Array.isArray(error) ? error.join(', ') : error

  return (
    <label className="block">
      <div className="mb-1.5 flex items-baseline justify-between gap-3">
        <span className="text-sm font-semibold text-slate-800">{label}</span>
        {hint && <span className="text-xs text-slate-500">{hint}</span>}
      </div>
      {children}
      {message && <p className="mt-1.5 text-sm text-rose-600">{message}</p>}
    </label>
  )
}

export function Input(props: InputHTMLAttributes<HTMLInputElement>) {
  return <input className={inputClasses} {...props} />
}

export function Select(props: SelectHTMLAttributes<HTMLSelectElement>) {
  return <select className={inputClasses} {...props} />
}
