import { Head, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { TextLink } from '@/atoms/TextLink/TextLink'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'
import { GuestLayout } from '@/templates/GuestLayout/GuestLayout'

type LoginPageProps = {
  urls: {
    login_url: string
    register_url: string
    forgot_password_url: string
  }
}

export default function Login({ urls }: LoginPageProps) {
  const { data, setData, post, processing, errors } = useForm({
    email_address: '',
    password: '',
  })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    post(urls.login_url)
  }

  return (
    <>
      <Head title="Sign in" />
      <GuestLayout
        title="Sign in"
        links={
          <>
            <TextLink href={urls.register_url}>Create an account</TextLink>
            <TextLink href={urls.forgot_password_url}>Forgot your password?</TextLink>
          </>
        }
      >
        <Form onSubmit={handleSubmit}>
          <Field label="Email address" htmlFor="login_email" error={errors.email_address?.[0]}>
            <TextInput
              id="login_email"
              type="email"
              name="email_address"
              autoComplete="username"
              value={data.email_address}
              onChange={(event) => setData('email_address', event.target.value)}
              autoFocus
              required
            />
          </Field>
          <Field label="Password" htmlFor="login_password" error={errors.password?.[0]}>
            <TextInput
              id="login_password"
              type="password"
              name="password"
              autoComplete="current-password"
              value={data.password}
              onChange={(event) => setData('password', event.target.value)}
              maxLength={72}
              required
            />
          </Field>
          <Button type="submit" disabled={processing}>
            {processing ? 'Signing in…' : 'Sign in'}
          </Button>
        </Form>
      </GuestLayout>
    </>
  )
}
