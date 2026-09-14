import { Children, cloneElement, useId, type ReactElement, type ReactNode } from 'react'

type Props = {
  label: string
  /** Rails sends every error as an array of messages (see `errorValueType` in types/globals.d.ts). */
  error?: string[] | string
  hint?: string
  children: ReactNode
}

type Control = ReactElement<{
  id?: string
  'aria-invalid'?: boolean
  'aria-describedby'?: string
}>

export default function Field({ label, error, hint, children }: Props) {
  const id = useId()
  const messages = error === undefined ? [] : [error].flat()
  const describedBy = [hint && `${id}-hint`, messages.length && `${id}-error`]
    .filter(Boolean)
    .join(' ')

  const control = cloneElement(Children.only(children) as Control, {
    id,
    'aria-invalid': messages.length > 0 || undefined,
    'aria-describedby': describedBy || undefined,
  })

  return (
    <div>
      <label htmlFor={id} className="block text-sm font-medium text-slate-700">
        {label}
      </label>
      <div className="mt-1">{control}</div>

      {hint && (
        <p id={`${id}-hint`} className="mt-1 text-xs text-slate-500">
          {hint}
        </p>
      )}

      {messages.length > 0 && (
        <p id={`${id}-error`} className="mt-1 text-xs text-red-600">
          {messages.join(', ')}
        </p>
      )}
    </div>
  )
}
