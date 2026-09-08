import { forwardRef } from 'react'
import type {
  ComponentPropsWithoutRef,
  ElementType,
  ForwardRefExoticComponent,
  RefAttributes,
} from 'react'

import { cn } from './cn'
import { resolveVariants, stripVariantProps, type VariantConfig } from './variants'

// Extract the trailing VariantConfig item (if any) from the args tuple.
type Last<T extends unknown[]> = T extends [...unknown[], infer L] ? L : never

export type VariantProps<TArgs extends unknown[]> =
  Last<TArgs> extends {
    variants: infer V extends Record<string, Record<string, string>>
  }
    ? { [K in keyof V]?: string }
    : {}

// The styled element accepts the variant props (each `?: string`), the native
// tag props, `as`, and a className. The index signature keeps unknown variant
// props pass-through while not blocking children/style/events.
export type StyledComponentOutput<TTag extends ElementType, TProps> = ForwardRefExoticComponent<
  { as?: ElementType; className?: string } & TProps &
    ComponentPropsWithoutRef<TTag> & { [key: string]: unknown } & RefAttributes<any> // eslint-disable-line no-any/no-any -- boundary: React's tag-specific ref union is untyped here
>

type OwnProps = {
  as?: ElementType
  className?: string
  [key: string]: unknown
}

// Factory: styled(tag, ...baseClasses, { variants, defaults }).
// Merge order (cn): base -> selected variants -> consumer className.
export function styled<TTag extends ElementType, TArgs extends Array<string | VariantConfig>>(
  Tag: TTag,
  ...args: TArgs
): StyledComponentOutput<TTag, VariantProps<TArgs>> {
  const base: string[] = []
  let config: VariantConfig | undefined

  for (const arg of args) {
    if (typeof arg === 'string') {
      base.push(arg)
    } else {
      config = arg
    }
  }

  const Styled = forwardRef<HTMLElement, OwnProps>(function Styled(
    { as, className, ...rest },
    ref,
  ) {
    const Comp = (as ?? Tag) as ElementType
    const variantClasses = resolveVariants(config, rest)
    const domProps = stripVariantProps(config, { ...rest })
    delete domProps.as
    delete domProps.className

    return (
      <Comp
        ref={ref as never}
        className={cn(...base, ...variantClasses, className as string | undefined)}
        {...domProps}
      />
    )
  })
  Styled.displayName = typeof Tag === 'string' ? `Styled(${Tag})` : 'Styled(Component)'

  return Styled as unknown as StyledComponentOutput<TTag, VariantProps<TArgs>>
}

// css(...): typed identity for class bundles and variant maps. The return type
// preserves the exact shape so it can feed `styled`'s VariantConfig trivially.
export function css<T>(value: T): T {
  return value
}

const TAGS = [
  'a',
  'button',
  'div',
  'fieldset',
  'form',
  'h1',
  'h2',
  'h3',
  'header',
  'img',
  'input',
  'label',
  'main',
  'nav',
  'p',
  'section',
  'select',
  'span',
  'svg',
  'table',
  'tbody',
  'td',
  'th',
  'thead',
  'tr',
  'ul',
  'li',
  'dt',
  'dd',
] as const

type SupportedTag = (typeof TAGS)[number]

type TagShorthand = {
  [K in SupportedTag]: <TArgs extends Array<string | VariantConfig>>(
    ...args: TArgs
  ) => StyledComponentOutput<K, VariantProps<TArgs>>
}

// styled.button('base', {...}) — tag shorthand (spec §3.1).
export const styledWithShorthand = Object.assign(
  styled,
  Object.fromEntries(TAGS.map((tag) => [tag, (...args: never[]) => styled(tag, ...args)])) as never,
) as typeof styled & TagShorthand
