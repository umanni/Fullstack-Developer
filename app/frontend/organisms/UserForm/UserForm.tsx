import { useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Avatar } from '@/atoms/Avatar/Avatar'
import { Button } from '@/atoms/Button/Button'
import { ButtonLink } from '@/atoms/Button/ButtonLink'
import { Select } from '@/atoms/Select/Select'
import { TextInput } from '@/atoms/TextInput/TextInput'
import { Field } from '@/molecules/Field/Field'
import { Form } from '@/molecules/Form/Form'

import { FormActions } from '@/molecules/Form/FormActions'
import { FormErrorAlert } from '@/organisms/FormErrorAlert/FormErrorAlert'
import type { UserFormData } from '@/types'

export type UserFormProps = {
  isEdit: boolean
  submitLabel: string
  avatarSource?: string
  urls: { submit_url: string; cancel_url: string }
  form?: UserFormData
}

// Admin create/edit user form (SPA put/post with multipart for the avatar).
export function UserForm({ isEdit, submitLabel, avatarSource, urls, form }: UserFormProps) {
  const { data, setData, post, put, processing, errors } = useForm({
    full_name: form?.full_name ?? '',
    email_address: form?.email_address ?? '',
    avatar_url: form?.avatar_url ?? '',
    role: form?.role ?? 'user',
    password: '',
    password_confirmation: '',
    avatar: null as File | null,
  })

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const options = { forceFormData: true }
    if (isEdit) {
      put(urls.submit_url, options)
    } else {
      post(urls.submit_url, options)
    }
  }

  return (
    <Form onSubmit={handleSubmit}>
      {avatarSource ? (
        <Avatar src={avatarSource} size="lg" alt={data.full_name || 'Avatar'} />
      ) : null}
      <Field label="Full name" htmlFor="user_full_name" error={errors.full_name?.[0]}>
        <TextInput
          id="user_full_name"
          name="full_name"
          autoComplete="name"
          value={data.full_name}
          onChange={(event) => setData('full_name', event.target.value)}
          required
        />
      </Field>
      <Field label="Email address" htmlFor="user_email" error={errors.email_address?.[0]}>
        <TextInput
          id="user_email"
          type="email"
          name="email_address"
          autoComplete="username"
          value={data.email_address}
          onChange={(event) => setData('email_address', event.target.value)}
          required
        />
      </Field>
      <Field label="Avatar" htmlFor="user_avatar" hint="Upload an image file.">
        <TextInput
          id="user_avatar"
          type="file"
          name="avatar"
          accept="image/png,image/jpeg,image/webp,image/gif,image/svg+xml"
          onChange={(event) => setData('avatar', event.target.files?.[0] ?? null)}
        />
      </Field>
      <Field
        label="Avatar URL"
        htmlFor="user_avatar_url"
        hint="Upload an image or provide a URL that starts with http(s)://."
        error={errors.avatar_url?.[0]}
      >
        <TextInput
          id="user_avatar_url"
          type="url"
          name="avatar_url"
          placeholder="https://..."
          value={data.avatar_url}
          onChange={(event) => setData('avatar_url', event.target.value)}
        />
      </Field>
      <Field label="Role" htmlFor="user_role" error={errors.role?.[0]}>
        <Select
          id="user_role"
          name="role"
          value={data.role}
          onChange={(event) => setData('role', event.target.value)}
        >
          <option value="user">User</option>
          <option value="admin">Admin</option>
        </Select>
      </Field>
      <Field
        label="Password"
        htmlFor="user_password"
        hint={isEdit ? 'Leave blank to keep the current password.' : undefined}
        error={errors.password?.[0]}
      >
        <TextInput
          id="user_password"
          type="password"
          name="password"
          autoComplete="new-password"
          value={data.password}
          onChange={(event) => setData('password', event.target.value)}
          minLength={8}
          maxLength={72}
          required={!isEdit}
        />
      </Field>
      <Field
        label="Confirm password"
        htmlFor="user_password_confirmation"
        error={errors.password_confirmation?.[0]}
      >
        <TextInput
          id="user_password_confirmation"
          type="password"
          name="password_confirmation"
          autoComplete="new-password"
          value={data.password_confirmation}
          onChange={(event) => setData('password_confirmation', event.target.value)}
          maxLength={72}
          required={!isEdit}
        />
      </Field>
      <FormErrorAlert errors={errors as Record<string, string[]>} />
      <FormActions>
        <Button type="submit" disabled={processing}>
          {submitLabel}
        </Button>
        <ButtonLink href={urls.cancel_url} variant="secondary">
          Cancel
        </ButtonLink>
      </FormActions>
    </Form>
  )
}
