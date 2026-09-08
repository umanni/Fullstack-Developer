// Tailwind utility classes as JSX string literals belong in a co-located
// *.styles.ts file (frontend-styles.md §3). The rule only targets the literal
// form; `className={cn(...)}` composition inside atoms stays legal.
export const noLiteralClassName = {
  meta: {
    type: 'problem',
    schema: [],
    docs: { description: 'Tailwind utilities only via co-located *.styles.ts' },
  },
  create(context) {
    return {
      JSXAttribute(node) {
        if (node.name?.type !== 'JSXIdentifier' || node.name.name !== 'className') return

        const { value } = node
        if (value?.type === 'Literal' && typeof value.value === 'string') {
          context.report({
            node,
            message:
              'Tailwind utility classes belong in a co-located *.styles.ts file; use styled(...) or className={cn(...)}.',
          })
        }
      },
    }
  },
}
