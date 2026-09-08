import { Head, Link, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/components/Button'
import { Field, Input } from '@/components/FormField'
import { AuthLayout } from '@/layouts/AuthLayout'
import { routes } from '@/lib/routes'

type RegistrationData = {
  full_name: string
  email: string
  password: string
  password_confirmation: string
  avatar_image: File | null
}

export default function Register() {
  const form = useForm<RegistrationData>({
    full_name: '',
    email: '',
    password: '',
    password_confirmation: '',
    avatar_image: null,
  })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    form.transform((data) => ({ user: data }))
    form.post(routes.registration, {
      forceFormData: true,
      onFinish: () => form.reset('password', 'password_confirmation'),
    })
  }

  return (
    <AuthLayout
      description="Create your personal profile. New registrations always start with standard user access."
      title="Create your account"
    >
      <Head title="Create account" />
      <form className="space-y-5" onSubmit={submit}>
        <Field error={form.errors.full_name} label="Full name">
          <Input
            autoComplete="name"
            maxLength={100}
            onChange={(event) => form.setData('full_name', event.target.value)}
            required
            value={form.data.full_name}
          />
        </Field>
        <Field error={form.errors.email} label="Email address">
          <Input
            autoComplete="email"
            maxLength={254}
            onChange={(event) => form.setData('email', event.target.value)}
            required
            type="email"
            value={form.data.email}
          />
        </Field>
        <Field
          error={form.errors.avatar_image}
          hint="Optional · JPG, PNG or WebP · max 5 MB"
          label="Avatar"
        >
          <Input
            accept="image/jpeg,image/png,image/webp"
            onChange={(event) =>
              form.setData('avatar_image', event.target.files?.[0] ?? null)
            }
            type="file"
          />
        </Field>
        <Field
          error={form.errors.password}
          hint="At least 12 characters"
          label="Password"
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
          label="Confirm password"
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
          {form.processing ? 'Creating account…' : 'Create account'}
        </Button>
      </form>
      <p className="mt-7 text-center text-sm text-slate-600">
        Already have an account?{' '}
        <Link
          className="font-semibold text-brand-700 hover:text-brand-800"
          href={routes.login}
        >
          Sign in
        </Link>
      </p>
    </AuthLayout>
  )
}
