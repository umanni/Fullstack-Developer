import { StyledCard, StyledLabel, StyledValue } from './StatCard.styles'

export type StatCardProps = {
  label: string
  value: number
}

// Numeric summary tile for the dashboard overview.
export function StatCard({ label, value }: StatCardProps) {
  return (
    <StyledCard>
      <StyledLabel>{label}</StyledLabel>
      <StyledValue>{value}</StyledValue>
    </StyledCard>
  )
}
