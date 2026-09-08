import js from '@eslint/js'
import babelParser from '@babel/eslint-parser'
import prettier from 'eslint-config-prettier'
import reactHooks from 'eslint-plugin-react-hooks'
import globals from 'globals'

import { noAny } from './eslint/no-any.mjs'
import { noLiteralClassName } from './eslint/no-literal-class-name.mjs'

const reactHooksRules = reactHooks.configs['recommended-latest'] ??
  reactHooks.configs.recommended ?? { rules: {} }

export default [
  {
    ignores: ['node_modules/**', 'app/frontend/build/**', 'public/**', 'coverage/**', 'vendor/**'],
  },
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs}'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: globals.node,
    },
  },
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      parser: babelParser,
      parserOptions: {
        requireConfigFile: false,
        babelOptions: {
          plugins: ['@babel/plugin-syntax-typescript', '@babel/plugin-syntax-jsx'],
        },
      },
      globals: {
        ...globals.browser,
        ...globals.es2022,
      },
    },
    plugins: {
      'react-hooks': reactHooks,
      'no-any': { rules: { 'no-any': noAny } },
      'no-literal-class-name': { rules: { 'no-literal-class-name': noLiteralClassName } },
    },
    rules: {
      ...reactHooksRules.rules,
      // Types are checked by `tsc` (tsconfig) — the JS rule would only add
      // noise for `import type` constructs parsed via Babel.
      'no-unused-vars': 'off',
      'no-undef': 'off',
      'no-any/no-any': 'error',
      'no-literal-class-name/no-literal-class-name': 'error',
    },
  },
  {
    files: ['**/*.{test,spec}.{ts,tsx}'],
    rules: {
      // Tests exercise the consumer override API (Button/TextInput className
      // merging) — the app-body rule does not apply to them.
      'no-literal-class-name/no-literal-class-name': 'off',
    },
  },
  prettier,
]
