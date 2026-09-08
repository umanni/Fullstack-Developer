import { Avatar } from '@/atoms/Avatar/Avatar'
import { Heading } from '@/atoms/Heading/Heading'

import { StyledEmail, StyledWrap } from './ProfileHeader.styles'

export type ProfileHeaderProps = {
  src: string | null | undefined
  name: string
  email?: string
}

// Centered avatar + identity used at the top of the profile page.
export function ProfileHeader({ src, name, email }: ProfileHeaderProps) {
  return (
    <StyledWrap>
      <Avatar src={src} alt={name} size="lg" />
      <Heading size="md">{name}</Heading>
      {email ? <StyledEmail>{email}</StyledEmail> : null}
    </StyledWrap>
  )
}
