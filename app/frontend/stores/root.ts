import { DashboardStore } from './dashboard-store'
import { FlashStore } from './flash-store'
import { ImportsStore } from './imports-store'
import { SessionStore } from './session-store'

// Composition root: every store is constructed here and provided down the
// tree through React Context (no global singleton). Stores only talk to each
// other through this root when composition requires it.
export class RootStore {
  session: SessionStore
  flash: FlashStore
  dashboard: DashboardStore
  imports: ImportsStore

  constructor() {
    this.session = new SessionStore()
    this.flash = new FlashStore()
    this.dashboard = new DashboardStore()
    this.imports = new ImportsStore()
  }
}
