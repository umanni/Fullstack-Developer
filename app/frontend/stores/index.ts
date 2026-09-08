import { configure } from 'mobx'

// Strict mode: state changes only allowed inside actions (applyAction /
// makeAutoObservable methods). UI must never mutate a store directly.
configure({ enforceActions: 'always' })

export { RootStore } from './root'
export { RootStoreProvider, useStore } from './store-context'
export { SessionStore } from './session-store'
export { FlashStore } from './flash-store'
export { DashboardStore } from './dashboard-store'
export { ImportsStore, type ImportProgress } from './imports-store'
