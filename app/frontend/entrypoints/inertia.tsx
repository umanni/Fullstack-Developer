import { createInertiaApp } from '@inertiajs/react'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

import { App } from '../App'
import { RootStoreProvider } from '../stores/store-context'

void createInertiaApp({
  pages: '../pages',

  setup({ el, App: InertiaApp, props }) {
    if (!el) return
    createRoot(el).render(
      <StrictMode>
        <RootStoreProvider>
          <App initialPage={props.initialPage}>
            <InertiaApp {...props} />
          </App>
        </RootStoreProvider>
      </StrictMode>,
    )
  },

  strictMode: true,

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    visitOptions: () => {
      return { queryStringArrayFormat: 'brackets' }
    },
  },
}).catch((error) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById('app')) {
    throw error
  } else {
    console.error(
      'Missing root element.\n\n' +
        'If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n' +
        'Consider moving <%= vite_typescript_tag "inertia.tsx" %> to the Inertia-specific layout instead.',
    )
  }
})
