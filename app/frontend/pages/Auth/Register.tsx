import { Head, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { TextLink } from '@/atoms/TextLink/TextLink'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'
import { FormErrorAlert } from '@/organisms/FormErrorAlert/FormErrorAlert'
import { GuestLayout } from '@/templates/GuestLayout/GuestLayout'

type RegisterPageProps = {
  urls: {
    register_url: string
    login_url: string
  }
  form?: {
    full_name?: string
    email_address?: string
    avatar_url?: string
  }
}

export default function Register({ urls, form }: RegisterPageProps) {
  const { data, setData, post, processing, errors } = useForm({
    full_name: form?.full_name ?? '',
    email_address: form?.email_address ?? '',
    avatar_url: form?.avatar_url ?? '',
    password: '',
    password_confirmation: '',
    avatar: null as File | null,
  })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    post(urls.register_url, { forceFormData: true })
  }

  return (
    <>
      <Head title="Create account" />
      <GuestLayout
        title="Create your account"
        links={<TextLink href={urls.login_url}>Already have an account? Sign in</TextLink>}
      >
        <Form onSubmit={handleSubmit}>
          <Field label="Full name" htmlFor="register_name" error={errors.full_name?.[0]}>
            <TextInput
              id="register_name"
              name="full_name"
              autoComplete="name"
              value={data.full_name}
              onChange={(event) => setData('full_name', event.target.value)}
              autoFocus
              required
            />
          </Field>
          <Field label="Email address" htmlFor="register_email" error={errors.email_address?.[0]}>
            <TextInput
              id="register_email"
              type="email"
              name="email_address"
              autoComplete="username"
              value={data.email_address}
              onChange={(event) => setData('email_address', event.target.value)}
              required
            />
          </Field>
          <Field label="Avatar" htmlFor="register_avatar" hint="Upload an image file.">
            <TextInput
              id="register_avatar"
              type="file"
              name="avatar"
              accept="image/png,image/jpeg,image/webp,image/gif,image/svg+xml"
              onChange={(event) => setData('avatar', event.target.files?.[0] ?? null)}
            />
          </Field>
          <Field
            label="Avatar URL (optional)"
            htmlFor="register_avatar_url"
            hint="Upload an image or provide a URL that starts with http(s)://."
            error={errors.avatar_url?.[0]}
          >
            <TextInput
              id="register_avatar_url"
              type="url"
              name="avatar_url"
              placeholder="https://..."
              value={data.avatar_url}
              onChange={(event) => setData('avatar_url', event.target.value)}
            />
          </Field>
          <Field label="Password" htmlFor="register_password" error={errors.password?.[0]}>
            <TextInput
              id="register_password"
              type="password"
              name="password"
              autoComplete="new-password"
              value={data.password}
              onChange={(event) => setData('password', event.target.value)}
              minLength={8}
              maxLength={72}
              required
            />
          </Field>
          <Field
            label="Confirm password"
            htmlFor="register_password_confirmation"
            error={errors.password_confirmation?.[0]}
          >
            <TextInput
              id="register_password_confirmation"
              type="password"
              name="password_confirmation"
              autoComplete="new-password"
              value={data.password_confirmation}
              onChange={(event) => setData('password_confirmation', event.target.value)}
              maxLength={72}
              required
            />
          </Field>
          <FormErrorAlert errors={errors as Record<string, string[]>} />
          <Button type="submit" disabled={processing}>
            {processing ? 'Creating account…' : 'Create account'}
          </Button>
        </Form>
      </GuestLayout>
    </>
  )
}
