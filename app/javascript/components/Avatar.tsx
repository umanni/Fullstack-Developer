import type { User } from '@/types'

function initials(fullName: string) {
  return fullName
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('')
}

type Props = {
  user: User
  size?: 'sm' | 'md'
}

const SIZES = {
  sm: 'h-8 w-8 text-xs',
  md: 'h-10 w-10 text-sm',
} as const

export default function Avatar({ user, size = 'sm' }: Props) {
  const base = `${SIZES[size]} shrink-0 rounded-full object-cover`

  if (user.avatar_url) {
    return <img src={user.avatar_url} alt="" aria-hidden className={`${base} bg-slate-100`} />
  }

  return (
    <span
      aria-hidden
      className={`${base} grid place-items-center bg-slate-200 font-medium text-slate-600`}
    >
      {initials(user.full_name)}
    </span>
  )
}
