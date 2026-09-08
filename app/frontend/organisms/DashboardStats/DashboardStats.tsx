import { observer } from 'mobx-react-lite'
import { useEffect } from 'react'

import { useChannel } from '@/lib/cable'
import { useStore } from '@/stores'
import type { UsersOverview } from '@/types'

import { StatCard } from '@/organisms/StatCard/StatCard'
import { StyledGrid } from './DashboardStats.styles'

export type DashboardStatsProps = {
  overview?: UsersOverview
}

// Real-time dashboard totals: hydrated from the initial Inertia props (same
// Users::Overview serialized in Phase 3 — DRY fallback) and kept live by the
// dashboard_stats stream. Receive -> store.ingest is the only realtime entry.
export const DashboardStats = observer(function DashboardStats({ overview }: DashboardStatsProps) {
  const { dashboard } = useStore()

  useEffect(() => {
    dashboard.hydrate(overview)
  }, [dashboard, overview])

  useChannel<UsersOverview>('DashboardChannel', {}, (payload) => {
    dashboard.ingest(payload)
  })

  return (
    <StyledGrid>
      <StatCard label="Total users" value={dashboard.total_users} />
      {Object.entries(dashboard.by_role).map(([role, count]) => (
        <StatCard key={role} label={`${role}s`} value={count} />
      ))}
    </StyledGrid>
  )
})
