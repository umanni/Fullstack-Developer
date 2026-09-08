import { Button } from '@/atoms/Button/Button'
import { Icon } from '@/atoms/Icon/Icon'
import { TextInput } from '@/atoms/TextInput/TextInput'

import { StyledSearchForm } from './SearchBar.styles'

export type SearchBarProps = {
  value: string
  onChange: (value: string) => void
  onSubmit: () => void
  placeholder?: string
  submitLabel?: string
}

// Query input + submit action wired to a caller-provided search function.
export function SearchBar({
  value,
  onChange,
  onSubmit,
  placeholder = 'Search',
  submitLabel = 'Search',
}: SearchBarProps) {
  return (
    <StyledSearchForm
      role="search"
      onSubmit={(event) => {
        event.preventDefault()
        onSubmit()
      }}
    >
      <TextInput
        type="search"
        name="search"
        placeholder={placeholder}
        aria-label={placeholder}
        value={value}
        onChange={(event) => onChange(event.target.value)}
      />
      <Button type="submit" variant="secondary">
        <Icon name="search" size="sm" />
        {submitLabel}
      </Button>
    </StyledSearchForm>
  )
}
