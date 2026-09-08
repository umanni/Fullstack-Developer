// Explicit `any` is only allowed at the styled() type boundary (with an
// eslint-disable + justification); everywhere else use unknown/specifics.
export const noAny = {
  meta: {
    type: 'problem',
    schema: [],
    docs: { description: 'Ban explicit any outside justified boundaries' },
  },
  create(context) {
    return {
      TSAnyKeyword(node) {
        context.report({
          node,
          message:
            'Avoid `any`; use `unknown`/the exact contract or justify an eslint-disable at the boundary.',
        })
      },
    }
  },
}
