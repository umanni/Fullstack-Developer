import { Badge } from '@/atoms/Badge/Badge'
import type { BadgeVariant } from '@/atoms/Badge/Badge.types'

export type RoleBadgeProps = {
  role: 'user' | 'admin'
}

// Role chip that reuses the badge style language (admin = brand tint).
export function RoleBadge({ role }: RoleBadgeProps) {
  const variant: BadgeVariant = role === 'admin' ? 'admin' : 'user'
  return <Badge variant={variant}>{role}</Badge>
}
