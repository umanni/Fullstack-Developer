import { useForm } from '@inertiajs/react'
import { FormEvent } from 'react'
import Field from '@/components/Field'
import { useLiveValidation } from '@/hooks/useLiveValidation'
import {
  avatarImage,
  avatarUrl,
  emailAddress,
  fullName,
  password,
  passwordConfirmation,
} from '@/lib/validation'
import type { User, UserRole } from '@/types'

type Props = {
  user?: User
  roles?: UserRole[]
  action: string
  method: 'post' | 'patch'
  submitLabel: string
}

export default function UserForm({ user, roles, action, method, submitLabel }: Props) {
  const form = useForm({
    full_name: user?.full_name ?? '',
    email_address: user?.email_address ?? '',
    password: '',
    password_confirmation: '',
    avatar_url: user?.remote_avatar_url ?? '',
    avatar_image: null as File | null,
    role: user?.role ?? ('member' as UserRole),
  })
  const { data, setData, errors, processing, progress } = form
  const validation = useLiveValidation(form, {
    full_name: fullName,
    email_address: emailAddress,
    // Editing keeps the current password when the field is left blank.
    password: password({ required: !user }),
    password_confirmation: passwordConfirmation,
    avatar_url: avatarUrl,
    avatar_image: avatarImage,
  })

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    if (!validation.validate(event.currentTarget)) return

    form.transform(({ avatar_image, ...fields }) => ({
      user: avatar_image ? { ...fields, avatar_image } : fields,
      ...(method === 'patch' ? { _method: 'patch' } : {}),
    }))
    form.post(action, { forceFormData: true, preserveScroll: true })
  }

  return (
    <form onSubmit={submit} className="max-w-lg space-y-4" noValidate>
      <Field label="Full name" error={errors.full_name}>
        <input
          value={data.full_name}
          onChange={(e) => validation.update('full_name', e.target.value)}
          onBlur={() => validation.touch('full_name')}
          required
          minLength={2}
          maxLength={120}
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
          className="input"
        />
      </Field>

      <Field
        label="Password"
        error={errors.password}
        hint={user ? 'Leave blank to keep current' : 'At least 8 characters'}
      >
        <input
          type="password"
          value={data.password}
          onChange={(e) => validation.update('password', e.target.value)}
          onBlur={() => validation.touch('password')}
          required={!user}
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
          autoComplete="new-password"
          className="input"
        />
      </Field>

      <Field label="Avatar upload" error={errors.avatar_image} hint="PNG, JPEG or WebP, under 5 MB">
        <input
          type="file"
          accept="image/png,image/jpeg,image/webp"
          onChange={(e) => validation.update('avatar_image', e.target.files?.[0] ?? null, true)}
          className="text-sm"
        />
      </Field>

      <Field
        label="Avatar URL"
        error={errors.avatar_url}
        hint="An https:// link, used when no file is uploaded"
      >
        <input
          type="url"
          value={data.avatar_url}
          onChange={(e) => validation.update('avatar_url', e.target.value)}
          onBlur={() => validation.touch('avatar_url')}
          className="input"
        />
      </Field>

      {roles && (
        <Field label="Role" error={errors.role}>
          <select
            value={data.role}
            onChange={(e) => setData('role', e.target.value as UserRole)}
            className="input"
          >
            {roles.map((role) => (
              <option key={role} value={role}>
                {role}
              </option>
            ))}
          </select>
        </Field>
      )}

      {progress && (
        <progress value={progress.percentage ?? 0} max={100} className="w-full">
          {progress.percentage}%
        </progress>
      )}

      <button
        type="submit"
        disabled={processing}
        className="rounded-md bg-slate-900 px-4 py-2 text-sm text-white hover:bg-slate-700 disabled:opacity-50"
      >
        {processing ? 'Saving...' : submitLabel}
      </button>
    </form>
  )
}
