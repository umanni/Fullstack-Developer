import { Head, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { TextLink } from '@/atoms/TextLink/TextLink'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'
import { GuestLayout } from '@/templates/GuestLayout/GuestLayout'

type ResetPasswordPageProps = {
  token: string
  urls: {
    login_url: string
  }
}

export default function ResetPassword({ token, urls }: ResetPasswordPageProps) {
  const { data, setData, put, processing, errors } = useForm({
    password: '',
    password_confirmation: '',
  })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    put(`/passwords/${encodeURIComponent(token)}`)
  }

  return (
    <>
      <Head title="Reset password" />
      <GuestLayout
        title="Choose a new password"
        links={<TextLink href={urls.login_url}>Back to sign in</TextLink>}
      >
        <Form onSubmit={handleSubmit}>
          <Field label="New password" htmlFor="reset_password" error={errors.password?.[0]}>
            <TextInput
              id="reset_password"
              type="password"
              name="password"
              autoComplete="new-password"
              value={data.password}
              onChange={(event) => setData('password', event.target.value)}
              minLength={8}
              maxLength={72}
              autoFocus
              required
            />
          </Field>
          <Field
            label="Confirm new password"
            htmlFor="reset_password_confirmation"
            error={errors.password_confirmation?.[0]}
          >
            <TextInput
              id="reset_password_confirmation"
              type="password"
              name="password_confirmation"
              autoComplete="new-password"
              value={data.password_confirmation}
              onChange={(event) => setData('password_confirmation', event.target.value)}
              maxLength={72}
              required
            />
          </Field>
          <Button type="submit" disabled={processing}>
            Save password
          </Button>
        </Form>
      </GuestLayout>
    </>
  )
}
