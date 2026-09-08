import { observer } from 'mobx-react-lite'

import { Alert } from '@/atoms/Alert/Alert'
import { useStore } from '@/stores'

import { StyledWrap } from './FlashMessages.styles'

// One-off user feedback rendered from the session flash. Observer reads the
// FlashStore (hydrated on every navigation by the App bridge).
export const FlashMessages = observer(function FlashMessages() {
  const { flash } = useStore()
  if (!flash.hasMessage) return null

  return (
    <StyledWrap aria-live="polite">
      {flash.notice ? <Alert variant="success">{flash.notice}</Alert> : null}
      {flash.alert ? <Alert variant="danger">{flash.alert}</Alert> : null}
    </StyledWrap>
  )
})
