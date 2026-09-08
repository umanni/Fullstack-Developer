import { useEffect, useRef } from 'react'
import { createPortal } from 'react-dom'

import { Button } from '@/atoms/Button/Button'
import { Heading } from '@/atoms/Heading/Heading'

import {
  StyledActions,
  StyledBackdrop,
  StyledDescription,
  StyledPanel,
} from './ConfirmDialog.styles'

export type ConfirmDialogProps = {
  open: boolean
  title: string
  description?: string
  confirmLabel?: string
  cancelLabel?: string
  onConfirm: () => void
  onCancel: () => void
}

const FOCUSABLE =
  'a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'
const TITLE_ID = 'confirm-dialog-title'

// Confirmation modal (portal + overlay) with a Tab/Shift+Tab focus trap and
// Escape-to-cancel. Focus returns to the opener on close.
export function ConfirmDialog({
  open,
  title,
  description,
  confirmLabel = 'Delete',
  cancelLabel = 'Cancel',
  onConfirm,
  onCancel,
}: ConfirmDialogProps) {
  const panelRef = useRef<HTMLDivElement | null>(null)
  const onConfirmRef = useRef(onConfirm)
  const onCancelRef = useRef(onCancel)

  // Keep the latest callbacks fresh without re-running the focus/keyboard
  // effect below (react-hooks/refs).
  useEffect(() => {
    onConfirmRef.current = onConfirm
    onCancelRef.current = onCancel
  })

  useEffect(() => {
    if (!open) return

    const previousFocus = document.activeElement as HTMLElement | null

    function focusables() {
      return Array.from(panelRef.current?.querySelectorAll<HTMLElement>(FOCUSABLE) ?? []).filter(
        (el) => el.offsetParent !== null || el === document.activeElement,
      )
    }

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        event.preventDefault()
        onCancelRef.current()
        return
      }
      if (event.key !== 'Tab') return
      const items = focusables()
      if (items.length === 0) {
        event.preventDefault()
        return
      }
      const first = items[0]
      const last = items[items.length - 1]
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault()
        last.focus()
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault()
        first.focus()
      }
    }

    focusables()[0]?.focus()
    document.addEventListener('keydown', handleKeyDown)
    const previousOverflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'

    return () => {
      document.removeEventListener('keydown', handleKeyDown)
      document.body.style.overflow = previousOverflow
      previousFocus?.focus()
    }
  }, [open])

  if (!open) return null

  return createPortal(
    <StyledBackdrop>
      <StyledPanel ref={panelRef} role="dialog" aria-modal="true" aria-labelledby={TITLE_ID}>
        <Heading as="h2" size="sm" id={TITLE_ID}>
          {title}
        </Heading>
        {description ? <StyledDescription>{description}</StyledDescription> : null}
        <StyledActions>
          <Button variant="secondary" type="button" onClick={() => onCancelRef.current()}>
            {cancelLabel}
          </Button>
          <Button variant="danger" type="button" onClick={() => onConfirmRef.current()}>
            {confirmLabel}
          </Button>
        </StyledActions>
      </StyledPanel>
    </StyledBackdrop>,
    document.body,
  )
}
