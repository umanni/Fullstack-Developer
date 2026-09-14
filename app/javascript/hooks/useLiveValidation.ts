import { useRef } from 'react'
import type { Rules, Validator } from '@/lib/validation'

/** The part of Inertia's `useForm` this hook works through. */
type Form<D> = {
  data: D
  errors: Partial<Record<keyof D, string[]>>
  setData<K extends keyof D>(field: K, value: D[K]): void
  setError(field: keyof D, messages: string[]): void
  clearErrors(...fields: (keyof D)[]): void
}

/**
 * Runs `rules` against an Inertia form while the user works through it: a field is checked
 * when it loses focus, then on every change after that, and every rule runs on submit.
 * Failures land in `form.errors`, where server errors land too, so <Field> shows both alike.
 */
export function useLiveValidation<D extends object>(form: Form<D>, rules: NoInfer<Rules<D>>) {
  const touched = useRef(new Set<keyof D>())
  const fields = Object.keys(rules) as (keyof D)[]

  const check = (data: D, only: Iterable<keyof D>) => {
    let valid = true

    for (const field of only) {
      const message = (rules[field] as Validator<D> | undefined)?.(data[field], data) ?? null

      if (message) {
        valid = false
        form.setError(field, [message])
      } else if (form.errors[field]) {
        form.clearErrors(field)
      }
    }

    return valid
  }

  /** Pass `commit` for controls finished in one step, such as file pickers. */
  const update = <K extends keyof D>(field: K, value: D[K], commit = false) => {
    form.setData(field, value)
    // A server error on the field counts as touched: editing it should re-check, not leave it standing.
    if (commit || form.errors[field]) touched.current.add(field)
    check({ ...form.data, [field]: value } as D, touched.current)
  }

  const touch = (field: keyof D) => {
    touched.current.add(field)
    check(form.data, [field])
  }

  /** Checks every rule; when one fails, moves focus to the first invalid control in `scope`. */
  const validate = (scope?: ParentNode | null) => {
    fields.forEach((field) => touched.current.add(field))
    const valid = check(form.data, fields)

    if (!valid && scope) {
      // Deferred until React has committed the aria-invalid attributes <Field> derives from errors.
      setTimeout(() => scope.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus())
    }

    return valid
  }

  return { update, touch, validate }
}
