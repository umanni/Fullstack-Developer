import { createContext, useContext, useState, type ReactNode } from 'react'

import { RootStore } from './root'

const StoreContext = createContext<RootStore | null>(null)

export function RootStoreProvider({ children }: { children: ReactNode }) {
  const [root] = useState(() => new RootStore())
  return <StoreContext.Provider value={root}>{children}</StoreContext.Provider>
}

export function useStore(): RootStore {
  const store = useContext(StoreContext)
  if (!store) throw new Error('useStore must be used within RootStoreProvider')
  return store
}
