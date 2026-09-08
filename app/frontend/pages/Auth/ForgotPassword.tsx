import { Head, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { TextLink } from '@/atoms/TextLink/TextLink'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'
import { GuestLayout } from '@/templates/GuestLayout/GuestLayout'

type ForgotPasswordPageProps = {
  urls: {
    login_url: string
  }
}

export default function ForgotPassword({ urls }: ForgotPasswordPageProps) {
  const { data, setData, post, processing, errors } = useForm({
    email_address: '',
  })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    post('/passwords')
  }

  return (
    <>
      <Head title="Forgot password" />
      <GuestLayout
        title="Forgot your password?"
        links={<TextLink href={urls.login_url}>Back to sign in</TextLink>}
      >
        <Form onSubmit={handleSubmit}>
          <Field label="Email address" htmlFor="forgot_email" error={errors.email_address?.[0]}>
            <TextInput
              id="forgot_email"
              type="email"
              name="email_address"
              autoComplete="username"
              value={data.email_address}
              onChange={(event) => setData('email_address', event.target.value)}
              autoFocus
              required
            />
          </Field>
          <Button type="submit" disabled={processing}>
            Send reset instructions
          </Button>
        </Form>
      </GuestLayout>
    </>
  )
}
