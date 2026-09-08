// Minimal variant resolution (internal mini-CVA). Variant props are extracted
// so they never leak to the DOM; defaults fill unspecified props. Resolution
// order preserved: base -> selected variants -> consumer className (in cn).

export type VariantMap = Record<string, Record<string, string>>

export type VariantConfig = {
  variants?: VariantMap
  defaults?: Record<string, string>
}

export function resolveVariants(
  config: VariantConfig | undefined,
  props: Record<string, unknown>,
): string[] {
  if (!config?.variants) return []
  return Object.entries(config.variants).map(([name, choices]) => {
    const prop = (props[name] ?? config.defaults?.[name]) as string | undefined
    return prop ? (choices[prop] ?? '') : ''
  })
}

// Variant placeholder keys are always stripped before spreading to the DOM.
export function stripVariantProps(
  config: VariantConfig | undefined,
  props: Record<string, unknown>,
): Record<string, unknown> {
  if (!config?.variants) return props
  for (const name of Object.keys(config.variants)) {
    delete props[name]
  }
  return props
}
