import { headingTags, StyledHeading } from './Heading.styles'
import type { HeadingProps } from './Heading.types'

// Semantic/sized heading. Element tag follows size (lg -> h1, md -> h2,
// sm -> h3) unless overridden with `as`.
export function Heading({ size = 'lg', ...rest }: HeadingProps) {
  return <StyledHeading as={headingTags[size]} size={size} {...rest} />
}
