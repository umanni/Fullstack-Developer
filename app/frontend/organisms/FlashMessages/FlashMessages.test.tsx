import { render, screen } from '@testing-library/react'
import { runInAction } from 'mobx'
import { describe, expect, it } from 'vitest'

import type { FlashData } from '@/types'

import { FlashMessages } from './FlashMessages'
import { RootStoreProvider, useStore } from '@/stores'

function setup(flash: FlashData) {
  function Probe() {
    const { flashStore } = { flashStore: useStore().flash }
    runInAction(() => {
      flashStore.notice = flash.notice
      flashStore.alert = flash.alert
    })
    return <FlashMessages />
  }
  return render(
    <RootStoreProvider>
      <Probe />
    </RootStoreProvider>,
  )
}

describe('FlashMessages', () => {
  it('renders nothing without a message', () => {
    const { container } = setup({})
    expect(container).toBeEmptyDOMElement()
  })

  it('renders the notice as a success alert', () => {
    setup({ notice: 'Saved!' })
    expect(screen.getByText('Saved!')).toBeInTheDocument()
  })

  it('renders the alert as a danger alert', () => {
    setup({ alert: 'Access denied' })
    expect(screen.getByRole('alert')).toHaveTextContent('Access denied')
  })
})
