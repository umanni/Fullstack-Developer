import { router } from '@inertiajs/react'
import { useEffect, type ReactNode } from 'react'

import { useStore } from '@/stores'
import type { SessionDP } from '@/types'

type AppProps = {
  children: ReactNode
  initialPage: { props: unknown }
}

// Bridge between the Inertia navigation stream and MobX.
//
// This wrapper renders ABOVE <InertiaApp/>, so the Inertia PageContext (which
// only exists deeper in the tree) is not available here — hence no usePage().
// Instead we read the initial page props passed from the entrypoint and keep
// the stores in sync through the global `navigate` event, which fires on every
// completed page swap (visits, partial reloads, history navigation).
export function App({ children, initialPage }: AppProps) {
  const { session, flash } = useStore()

  useEffect(() => {
    const hydrate = (pageProps: unknown) => {
      const props = pageProps as SessionDP
      session.hydrate(props.auth?.user ?? null)
      flash.hydrate(props.flash ?? {})
    }

    hydrate(initialPage.props)
    return router.on('navigate', (event) => {
      hydrate((event.detail.page as { props: unknown }).props)
    })
  }, [initialPage, session, flash])

  return <>{children}</>
}
