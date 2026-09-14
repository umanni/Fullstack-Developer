import { createInertiaApp } from '@inertiajs/react'
import { inertiaDefaults } from '@/lib/inertia'

// Server-side rendering entry. @inertiajs/vite (vite.config.ts) wraps this call in server code:
// `bin/vite dev` answers Rails at /__inertia_ssr, and `bin/vite build --ssr` (run by
// assets:precompile) emits public/vite-ssr/ssr.js, a Node server on port 13714 that the
// inertia_ssr Puma plugin keeps running. The browser then hydrates the HTML it returns.
createInertiaApp({
  pages: '../pages',
  defaults: inertiaDefaults,
})
