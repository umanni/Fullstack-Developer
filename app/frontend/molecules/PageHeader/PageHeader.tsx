import type { ReactNode } from 'react'

import { Heading } from '@/atoms/Heading/Heading'
import type { HeadingSize } from '@/atoms/Heading/Heading.types'

import { StyledDescription, StyledWrap } from './PageHeader.styles'

export type PageHeaderProps = {
  title: string
  description?: string
  action?: ReactNode
  size?: HeadingSize
}

// Title + optional subtitle and trailing action, shared by every content page.
export function PageHeader({ title, description, action, size = 'lg' }: PageHeaderProps) {
  return (
    <StyledWrap>
      <div>
        <Heading size={size}>{title}</Heading>
        {description ? <StyledDescription>{description}</StyledDescription> : null}
      </div>
      {action ? <div>{action}</div> : null}
    </StyledWrap>
  )
}
