import { useForm } from '@inertiajs/react'
import type { FormEvent } from 'react'

import { Avatar } from '@/components/Avatar'
import { Button, ButtonLink } from '@/components/Button'
import { Field, Input, Select } from '@/components/FormField'
import type { Role, User } from '@/types'

type UserFormData = {
  full_name: string
  email: string
  role: Role
  password: string
  password_confirmation: string
  avatar_image: File | null
  remove_avatar: boolean
}

type Props = {
  user?: User
  action: string
  cancelHref: string
  submitLabel: string
  allowRole?: boolean
}

export function UserForm({
  user,
  action,
  cancelHref,
  submitLabel,
  allowRole = false,
}: Props) {
  const isCreate = !user
  const form = useForm<UserFormData>({
    full_name: user?.full_name ?? '',
    email: user?.email ?? '',
    role: user?.role ?? 'user',
    password: '',
    password_confirmation: '',
    avatar_image: null,
    remove_avatar: false,
  })

  const submit = (event: FormEvent) => {
    event.preventDefault()
    const options = {
      forceFormData: true,
      onFinish: () => form.reset('password', 'password_confirmation'),
    }

    form.transform((data) => ({ user: data }))
    if (isCreate) form.post(action, options)
    else form.patch(action, options)
  }

  return (
    <form className="space-y-8" onSubmit={submit}>
      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-7">
        <div className="mb-6">
          <h2 className="font-semibold text-slate-950">Profile information</h2>
          <p className="mt-1 text-sm text-slate-500">
            The information used to identify this person across the workspace.
          </p>
        </div>
        <div className="grid gap-5 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <Field error={form.errors.full_name} label="Full name">
              <Input
                autoComplete="name"
                maxLength={100}
                onChange={(event) =>
                  form.setData('full_name', event.target.value)
                }
                required
                value={form.data.full_name}
              />
            </Field>
          </div>
          <div className={allowRole ? '' : 'sm:col-span-2'}>
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
          </div>
          {allowRole && (
            <Field error={form.errors.role} label="Role">
              <Select
                onChange={(event) =>
                  form.setData('role', event.target.value as Role)
                }
                value={form.data.role}
              >
                <option value="user">User</option>
                <option value="admin">Admin</option>
              </Select>
            </Field>
          )}
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-7">
        <div className="mb-6">
          <h2 className="font-semibold text-slate-950">Avatar</h2>
          <p className="mt-1 text-sm text-slate-500">
            A clear square image works best. JPEG, PNG and WebP files up to 5 MB
            are accepted.
          </p>
        </div>
        <div className="flex flex-col gap-5 sm:flex-row sm:items-center">
          <Avatar
            name={form.data.full_name || 'New user'}
            size="lg"
            src={form.data.remove_avatar ? null : (user?.avatar_url ?? null)}
          />
          <div className="flex-1">
            <Field error={form.errors.avatar_image} label="Upload an image">
              <Input
                accept="image/jpeg,image/png,image/webp"
                onChange={(event) =>
                  form.setData('avatar_image', event.target.files?.[0] ?? null)
                }
                type="file"
              />
            </Field>
            {user?.avatar_url && (
              <label className="mt-3 flex items-center gap-2 text-sm text-slate-600">
                <input
                  checked={form.data.remove_avatar}
                  className="rounded border-slate-300 text-brand-600 focus:ring-brand-500"
                  onChange={(event) =>
                    form.setData('remove_avatar', event.target.checked)
                  }
                  type="checkbox"
                />
                Remove current avatar
              </label>
            )}
          </div>
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm sm:p-7">
        <div className="mb-6">
          <h2 className="font-semibold text-slate-950">Password</h2>
          <p className="mt-1 text-sm text-slate-500">
            {isCreate
              ? 'Set a secure initial password.'
              : 'Leave both fields blank to keep the current password.'}
          </p>
        </div>
        <div className="grid gap-5 sm:grid-cols-2">
          <Field
            error={form.errors.password}
            hint="Minimum 12 characters"
            label={isCreate ? 'Password' : 'New password'}
          >
            <Input
              autoComplete="new-password"
              minLength={12}
              onChange={(event) => form.setData('password', event.target.value)}
              required={isCreate}
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
              required={isCreate || form.data.password.length > 0}
              type="password"
              value={form.data.password_confirmation}
            />
          </Field>
        </div>
      </section>

      <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
        <ButtonLink href={cancelHref} variant="secondary">
          Cancel
        </ButtonLink>
        <Button disabled={form.processing} type="submit">
          {form.processing ? 'Saving…' : submitLabel}
        </Button>
      </div>
    </form>
  )
}
