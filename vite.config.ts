import react from '@vitejs/plugin-react'
import inertia from '@inertiajs/vite'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig(({ isSsrBuild }) => ({
  plugins: [
    tailwindcss(),
    RubyPlugin(),
    // Relative to app/javascript, the root vite-plugin-ruby sets.
    inertia({ ssr: 'ssr/ssr.ts' }),
    react(),
  ],
  // The runtime Docker image has the node binary but no node_modules, so the SSR bundle
  // carries React and Inertia inside it.
  ssr: isSsrBuild ? { noExternal: true } : undefined,
}))
