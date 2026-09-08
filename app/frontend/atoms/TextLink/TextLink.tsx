import { Link } from '@inertiajs/react'
import type { ComponentProps } from 'react'
import { cn } from '@/lib/styled'

import { textLinkClass } from './TextLink.styles'

type TextLinkProps = ComponentProps<typeof Link> & {
  className?: string
}

// Inline navigation link (SPA — always an Inertia <Link>).
export function TextLink({ className, ...rest }: TextLinkProps) {
  return <Link className={cn(textLinkClass, className)} {...rest} />
}
