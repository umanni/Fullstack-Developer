import { Head, Link, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/components/Button'
import { Field, Input } from '@/components/FormField'
import { Icon } from '@/components/Icon'
import { AuthLayout } from '@/layouts/AuthLayout'
import { routes } from '@/lib/routes'

export default function ForgotPassword() {
  const form = useForm({ email: '' })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.transform((data) => ({ password: data }))
    form.post('/passwords')
  }

  return (
    <AuthLayout
      description="We'll send a secure reset link if the address belongs to an account."
      title="Reset your password"
    >
      <Head title="Forgot password" />
      <form className="space-y-5" onSubmit={submit}>
        <Field error={form.errors.email} label="Email address">
          <Input
            autoComplete="email"
            onChange={(event) => form.setData('email', event.target.value)}
            required
            type="email"
            value={form.data.email}
          />
        </Field>
        <Button className="w-full" disabled={form.processing} type="submit">
          {form.processing ? 'Sending…' : 'Send reset instructions'}
        </Button>
      </form>
      <Link
        className="mt-7 flex items-center justify-center gap-2 text-sm font-semibold text-brand-700 hover:text-brand-800"
        href={routes.login}
      >
        <Icon className="size-4" name="arrow-left" /> Back to sign in
      </Link>
    </AuthLayout>
  )
}
