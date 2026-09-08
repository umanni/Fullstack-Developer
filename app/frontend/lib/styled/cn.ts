import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

// Merge of class strings with Tailwind-aware override (base -> variants ->
// consumer className). Only lib/styled and *.styles.ts may use this.
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs))
}
