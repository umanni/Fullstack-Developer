import { makeAutoObservable } from 'mobx'

import type { User } from '@/types'

// Authenticated session snapshot. Hydrated from Inertia shared props on every
// navigation (reaction in App.tsx). No emitters — pages read via observer.
export class SessionStore {
  user: User | null = null

  constructor() {
    makeAutoObservable(this)
  }

  hydrate(user: User | null) {
    this.user = user
  }

  get isAuthenticated(): boolean {
    return this.user != null
  }

  get isAdmin(): boolean {
    return this.user?.role === 'admin'
  }

  get displayName(): string {
    return this.user?.full_name ?? this.user?.email_address ?? ''
  }

  get initials(): string {
    const name = this.displayName.trim()
    if (!name) return '?'
    const parts = name.split(/\s+/)
    return parts.length === 1
      ? parts[0].slice(0, 2).toUpperCase()
      : (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  }
}
