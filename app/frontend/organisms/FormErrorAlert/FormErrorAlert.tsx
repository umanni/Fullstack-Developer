import { Alert } from '@/atoms/Alert/Alert'

export type FormErrorAlertProps = {
  errors?: Record<string, string[] | undefined>
}

// Renders the form-level ("base"/"form") error banner, nothing otherwise.
export function FormErrorAlert({ errors }: FormErrorAlertProps) {
  const base = errors?.base ?? errors?.form
  if (!base || base.length === 0) return null

  return (
    <Alert variant="danger" title="Couldn't save">
      {base.join(' ')}
    </Alert>
  )
}
