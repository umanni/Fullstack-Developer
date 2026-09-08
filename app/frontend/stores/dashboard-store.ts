import { makeAutoObservable } from 'mobx'

import type { UsersOverview } from '@/types'

// Real-time snapshots of the admin dashboard totals. Same Users::Overview
// shape as the initial Inertia render (DRY — one payload contract).
export class DashboardStore {
  total_users = 0
  by_role: Record<string, number> = {}

  constructor() {
    makeAutoObservable(this)
  }

  hydrate(overview?: UsersOverview) {
    if (!overview) return
    this.total_users = overview.total_users
    this.by_role = { ...overview.by_role }
  }

  ingest(payload: UsersOverview) {
    this.total_users = payload.total_users
    this.by_role = { ...payload.by_role }
  }
}
