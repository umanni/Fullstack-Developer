import { Head, Link, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/components/Button'
import { Field, Input } from '@/components/FormField'
import { AuthLayout } from '@/layouts/AuthLayout'
import { routes } from '@/lib/routes'

export default function Login() {
  const form = useForm({ email: '', password: '' })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.transform((data) => ({ session: data }))
    form.post(routes.session, {
      onFinish: () => form.reset('password'),
    })
  }

  return (
    <AuthLayout
      description="Welcome back. Enter your details to continue."
      title="Sign in to your account"
    >
      <Head title="Sign in" />
      <form className="space-y-5" onSubmit={submit}>
        <Field error={form.errors.email} label="Email address">
          <Input
            autoComplete="email"
            name="email"
            onChange={(event) => form.setData('email', event.target.value)}
            placeholder="you@company.com"
            required
            type="email"
            value={form.data.email}
          />
        </Field>
        <Field error={form.errors.password} label="Password">
          <Input
            autoComplete="current-password"
            minLength={12}
            name="password"
            onChange={(event) => form.setData('password', event.target.value)}
            required
            type="password"
            value={form.data.password}
          />
        </Field>
        <div className="flex justify-end">
          <Link
            className="text-sm font-semibold text-brand-700 hover:text-brand-800"
            href={routes.forgotPassword}
          >
            Forgot password?
          </Link>
        </div>
        <Button className="w-full" disabled={form.processing} type="submit">
          {form.processing ? 'Signing in…' : 'Sign in'}
        </Button>
      </form>
      <p className="mt-7 text-center text-sm text-slate-600">
        New to PeopleHub?{' '}
        <Link
          className="font-semibold text-brand-700 hover:text-brand-800"
          href={routes.register}
        >
          Create an account
        </Link>
      </p>
    </AuthLayout>
  )
}
