import { configDefaults, defineConfig } from 'vitest/config'

// Frontend component tests mirror the app's bundler aliases (@/ -> app/frontend).
export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['app/frontend/**/*.test.{ts,tsx}'],
    exclude: [...configDefaults.exclude, 'node_modules', 'vendor'],
    setupFiles: ['./app/frontend/test/setup.ts'],
  },
  resolve: {
    alias: {
      '@': new URL('./app/frontend', import.meta.url).pathname,
      '~': new URL('./app/frontend', import.meta.url).pathname,
    },
  },
})
