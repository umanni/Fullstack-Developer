import { Head, Link, useForm } from '@inertiajs/react'
import { FormEvent } from 'react'
import AppLayout from '@/layouts/AppLayout'
import Field from '@/components/Field'
import { useLiveValidation } from '@/hooks/useLiveValidation'
import { emailAddress, fullName, password, passwordConfirmation } from '@/lib/validation'

export default function Register() {
  const form = useForm({
    full_name: '',
    email_address: '',
    password: '',
    password_confirmation: '',
  })
  const { data, errors, processing } = form
  const validation = useLiveValidation(form, {
    full_name: fullName,
    email_address: emailAddress,
    password: password({ required: true }),
    password_confirmation: passwordConfirmation,
  })

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (!validation.validate(event.currentTarget)) return

    form.transform((fields) => ({ user: fields }))
    form.post('/registration', { onError: () => form.reset('password', 'password_confirmation') })
  }

  return (
    <>
      <Head title="Create account" />

      <div className="mx-auto max-w-lg">
        <h1 className="text-2xl font-semibold tracking-tight">Create your account</h1>
        <p className="mt-2 text-sm text-slate-600">
          Already registered?{' '}
          {/* The sign-in page is a plain Rails view, not an Inertia page, so it needs a full page load. */}
          <a href="/session/new" className="text-slate-900 underline hover:no-underline">
            Sign in
          </a>
        </p>

        {/* noValidate: useLiveValidation shows the same inline messages in every browser, instead of
            each engine's own bubbles. The required/minLength attributes stay for assistive tech. */}
        <form onSubmit={submit} className="mt-6 space-y-4" noValidate>
          <Field label="Full name" error={errors.full_name}>
            <input
              value={data.full_name}
              onChange={(e) => validation.update('full_name', e.target.value)}
              onBlur={() => validation.touch('full_name')}
              required
              minLength={2}
              maxLength={120}
              autoComplete="name"
              autoFocus
              className="input"
            />
          </Field>

          <Field label="Email" error={errors.email_address}>
            <input
              type="email"
              value={data.email_address}
              onChange={(e) => validation.update('email_address', e.target.value)}
              onBlur={() => validation.touch('email_address')}
              required
              autoComplete="email"
              className="input"
            />
          </Field>

          <Field label="Password" error={errors.password} hint="At least 8 characters">
            <input
              type="password"
              value={data.password}
              onChange={(e) => validation.update('password', e.target.value)}
              onBlur={() => validation.touch('password')}
              required
              minLength={8}
              maxLength={72}
              autoComplete="new-password"
              className="input"
            />
          </Field>

          <Field label="Confirm password" error={errors.password_confirmation}>
            <input
              type="password"
              value={data.password_confirmation}
              onChange={(e) => validation.update('password_confirmation', e.target.value)}
              onBlur={() => validation.touch('password_confirmation')}
              required
              autoComplete="new-password"
              className="input"
            />
          </Field>

          <button
            type="submit"
            disabled={processing}
            className="w-full rounded-md bg-slate-900 px-4 py-2 text-sm text-white hover:bg-slate-700 disabled:opacity-50 sm:w-auto"
          >
            {processing ? 'Creating account...' : 'Create account'}
          </button>
        </form>

        <p className="mt-6 text-sm text-slate-500">
          <Link href="/" className="hover:underline">
            Back to home
          </Link>
        </p>
      </div>
    </>
  )
}

Register.layout = AppLayout
