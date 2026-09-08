import { Head, useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Button } from '@/atoms/Button/Button'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { Card } from '@/molecules/Card/Card'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'
import { FormActions } from '@/molecules/Form/FormActions'
import { PageHeader } from '@/molecules/PageHeader/PageHeader'
import { FormErrorAlert } from '@/organisms/FormErrorAlert/FormErrorAlert'
import { AuthenticatedLayout } from '@/templates/AuthenticatedLayout/AuthenticatedLayout'

type ProfileEditProps = {
  urls: {
    profile_url: string
    admin_url: string
    submit_url: string
    cancel_url: string
  }
  form?: {
    full_name?: string
    email_address?: string
    avatar_url?: string
  }
}

export default function ProfileEdit({ urls, form }: ProfileEditProps) {
  const { data, setData, put, processing, errors } = useForm({
    full_name: form?.full_name ?? '',
    email_address: form?.email_address ?? '',
    avatar_url: form?.avatar_url ?? '',
    password: '',
    password_confirmation: '',
    avatar: null as File | null,
  })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    put(urls.submit_url, { forceFormData: true })
  }

  return (
    <>
      <Head title="Edit profile" />
      <AuthenticatedLayout profileUrl={urls.profile_url} adminUrl={urls.admin_url}>
        <PageHeader title="Edit profile" />
        <Card>
          <Form onSubmit={handleSubmit}>
            <Field label="Full name" htmlFor="profile_name" error={errors.full_name?.[0]}>
              <TextInput
                id="profile_name"
                name="full_name"
                autoComplete="name"
                value={data.full_name}
                onChange={(event) => setData('full_name', event.target.value)}
                required
              />
            </Field>
            <Field label="Email address" htmlFor="profile_email" error={errors.email_address?.[0]}>
              <TextInput
                id="profile_email"
                type="email"
                name="email_address"
                autoComplete="username"
                value={data.email_address}
                onChange={(event) => setData('email_address', event.target.value)}
                required
              />
            </Field>
            <Field label="Avatar" htmlFor="profile_avatar" hint="Upload an image file.">
              <TextInput
                id="profile_avatar"
                type="file"
                name="avatar"
                accept="image/png,image/jpeg,image/webp,image/gif,image/svg+xml"
                onChange={(event) => setData('avatar', event.target.files?.[0] ?? null)}
              />
            </Field>
            <Field
              label="Avatar URL"
              htmlFor="profile_avatar_url"
              hint="Upload an image or provide a URL that starts with http(s)://."
              error={errors.avatar_url?.[0]}
            >
              <TextInput
                id="profile_avatar_url"
                type="url"
                name="avatar_url"
                placeholder="https://..."
                value={data.avatar_url}
                onChange={(event) => setData('avatar_url', event.target.value)}
              />
            </Field>
            <Field
              label="New password"
              htmlFor="profile_password"
              hint="Leave blank to keep the current password."
              error={errors.password?.[0]}
            >
              <TextInput
                id="profile_password"
                type="password"
                name="password"
                autoComplete="new-password"
                value={data.password}
                onChange={(event) => setData('password', event.target.value)}
                minLength={8}
                maxLength={72}
              />
            </Field>
            <Field
              label="Confirm new password"
              htmlFor="profile_password_confirmation"
              error={errors.password_confirmation?.[0]}
            >
              <TextInput
                id="profile_password_confirmation"
                type="password"
                name="password_confirmation"
                autoComplete="new-password"
                value={data.password_confirmation}
                onChange={(event) => setData('password_confirmation', event.target.value)}
                maxLength={72}
              />
            </Field>
            <FormErrorAlert errors={errors as Record<string, string[]>} />
            <FormActions>
              <Button type="submit" disabled={processing}>
                Save changes
              </Button>
              <ButtonLink href={urls.cancel_url} variant="secondary">
                Cancel
              </ButtonLink>
            </FormActions>
          </Form>
        </Card>
      </AuthenticatedLayout>
    </>
  )
}
