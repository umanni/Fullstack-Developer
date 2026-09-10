/**
 * Shared form field components for consistent validation UI.
 * // OptimizationRef: RB4-RM80-InertiaReact
 */

/** Displays a field-level validation error with accessible markup. */
export function FieldError({ error }) {
  if (!error) return null
  const message = Array.isArray(error) ? error[0] : error
  return (
    <p className="text-rose-600 text-sm mt-1 flex items-start gap-1" role="alert">
      <svg className="w-4 h-4 mt-0.5 shrink-0" fill="currentColor" viewBox="0 0 20 20">
        <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
      </svg>
      {message}
    </p>
  )
}

/** Displays server-wide (non-field) errors. */
export function FormErrors({ errors }) {
  if (!errors) return null
  // Rails returns { base: [...] } for non-field errors
  const base = errors.base
  if (!base) return null
  const messages = Array.isArray(base) ? base : [base]
  return (
    <div className="rounded-xl bg-rose-50 border border-rose-200 p-4 mb-4" role="alert">
      <p className="text-rose-800 font-semibold text-sm mb-1">Please fix the following errors:</p>
      <ul className="list-disc list-inside text-rose-700 text-sm space-y-0.5">
        {messages.map((msg, i) => <li key={i}>{msg}</li>)}
      </ul>
    </div>
  )
}

/** Password complexity hint shown below password fields. */
export function PasswordHint({ className = "" }) {
  return (
    <p className={`text-xs text-slate-500 mt-1 ${className}`}>
      Must be at least 8 characters with one uppercase letter, one lowercase letter, and one number.
    </p>
  )
}

/** Styled form input with consistent spacing. */
export const inputClass = "w-full rounded-xl border border-slate-300 px-4 py-3 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition"

/** Wraps a field with label, input, and error display. */
export function Field({ label, htmlFor, error, children, hint }) {
  return (
    <div>
      {label && <label htmlFor={htmlFor} className="block text-sm font-medium text-slate-700 mb-1">{label}</label>}
      {children}
      {hint}
      <FieldError error={error} />
    </div>
  )
}
