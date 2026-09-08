import { Head, Link, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/components/Button'
import { Field, Input } from '@/components/FormField'
import { AuthLayout } from '@/layouts/AuthLayout'
import { routes } from '@/lib/routes'

export default function ResetPassword({ token }: { token: string }) {
  const form = useForm({ password: '', password_confirmation: '' })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.transform((data) => ({ user: data }))
    form.patch(`/passwords/${token}`, {
      onFinish: () => form.reset(),
    })
  }

  return (
    <AuthLayout
      description="Choose a strong password that you don't use anywhere else."
      title="Choose a new password"
    >
      <Head title="Choose new password" />
      <form className="space-y-5" onSubmit={submit}>
        <Field
          error={form.errors.password}
          hint="At least 12 characters"
          label="New password"
        >
          <Input
            autoComplete="new-password"
            minLength={12}
            onChange={(event) => form.setData('password', event.target.value)}
            required
            type="password"
            value={form.data.password}
          />
        </Field>
        <Field
          error={form.errors.password_confirmation}
          label="Confirm new password"
        >
          <Input
            autoComplete="new-password"
            minLength={12}
            onChange={(event) =>
              form.setData('password_confirmation', event.target.value)
            }
            required
            type="password"
            value={form.data.password_confirmation}
          />
        </Field>
        <Button className="w-full" disabled={form.processing} type="submit">
          {form.processing ? 'Updating…' : 'Update password'}
        </Button>
      </form>
      <p className="mt-7 text-center text-sm text-slate-500">
        Remembered it?{' '}
        <Link className="font-semibold text-brand-700" href={routes.login}>
          Sign in
        </Link>
      </p>
    </AuthLayout>
  )
}
