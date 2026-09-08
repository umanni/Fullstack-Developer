import { makeAutoObservable, observable } from 'mobx'

import type { ImportStatus } from '@/types'

// Canonical, DB-shaped progress snapshot. The ProgressBroadcaster payload
// (Phase 5/6) is already in this shape; the presenter's AdminImport is mapped
// in the consumer before it touches the store (single shape in the store).
export type ImportProgress = {
  id: number
  status: ImportStatus
  total: number
  processed: number
  failed: number
  percent: number
}

// Real-time import progress keyed by UserImport id.
export class ImportsStore {
  imports = observable.map<number, ImportProgress>()

  constructor() {
    makeAutoObservable(this)
  }

  hydrate(id: number, data: ImportProgress) {
    this.imports.set(id, data)
  }

  ingest(payload: ImportProgress) {
    this.imports.set(payload.id, payload)
  }

  isTracked(id: number) {
    return this.imports.has(id)
  }

  progressOf(id: number) {
    return this.imports.get(id)
  }
}
