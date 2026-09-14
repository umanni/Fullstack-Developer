/**
 * Browser-side copies of the server's validations (User, Imports::UserRow, Import), so a
 * form can flag a bad value while the user is still on the field instead of after a round
 * trip. Messages match what Rails sends back, so a field reads the same whichever side
 * caught the problem. The server remains the authority: these never replace its checks.
 */

export type Validator<D, K extends keyof D = keyof D> = (value: D[K], data: D) => string | null
export type Rules<D> = { [K in keyof D]?: Validator<D, K> }

const MB = 1024 * 1024

// URI::MailTo::EMAIL_REGEXP, the pattern User#email_address is validated against.
const EMAIL =
  /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

const HTTPS_URL = /^https:\/\/\S+$/
const AVATAR_TYPES = ['image/png', 'image/jpeg', 'image/webp']

/** User normalizes full_name with `squish` before checking its length. */
const squish = (value: string) => value.trim().replace(/\s+/g, ' ')

export function fullName(value: string): string | null {
  const name = squish(value)
  if (!name) return "can't be blank"
  if (name.length < 2) return 'is too short (minimum is 2 characters)'
  if (name.length > 120) return 'is too long (maximum is 120 characters)'
  return null
}

export function emailAddress(value: string): string | null {
  const email = value.trim()
  if (!email) return "can't be blank"
  return EMAIL.test(email) ? null : 'is invalid'
}

/** has_secure_password: required on create, at least 8 characters, at most bcrypt's 72 bytes. */
export function password({ required }: { required: boolean }) {
  return (value: string): string | null => {
    if (!value) return required ? "can't be blank" : null
    if (value.length < 8) return 'is too short (minimum is 8 characters)'
    if (new TextEncoder().encode(value).length > 72) return 'is too long (maximum is 72 bytes)'
    return null
  }
}

export function passwordConfirmation(value: string, data: { password: string }): string | null {
  return value === data.password ? null : "doesn't match Password"
}

export function avatarUrl(value: string): string | null {
  const url = value.trim()
  return !url || HTTPS_URL.test(url) ? null : 'is invalid'
}

export function avatarImage(file: File | null): string | null {
  if (!file) return null
  if (!AVATAR_TYPES.includes(file.type)) return 'must be a PNG, JPEG or WebP image'
  if (file.size >= 5 * MB) return 'must be smaller than 5 MB'
  return null
}

/** Checked by extension: browsers report a CSV under several MIME types, or none at all. */
export function spreadsheet(file: File | null): string | null {
  if (!file) return "can't be blank"
  if (!/\.(csv|xlsx)$/i.test(file.name)) return 'must be a .csv or .xlsx file'
  if (file.size > 10 * MB) return 'must be smaller than 10 MB'
  return null
}
