/**
 * Options shared by the browser entry (entrypoints/inertia.tsx) and the SSR entry
 * (ssr/ssr.ts), so a page is set up the same way on both sides.
 */
export const inertiaDefaults = {
  form: {
    forceIndicesArrayFormatInFormData: false,
    withAllErrors: true,
  },
  visitOptions: () => ({ queryStringArrayFormat: 'brackets' as const }),
}
