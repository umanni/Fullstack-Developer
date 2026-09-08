import { makeAutoObservable } from 'mobx'

import type { FlashData } from '@/types'

// One-off user-feedback message carried by the session (Rails flash), hydrated
// from Inertia shared props on navigation and cleared on read.
export class FlashStore {
  notice: string | undefined
  alert: string | undefined

  constructor() {
    makeAutoObservable(this)
  }

  hydrate(flash: FlashData) {
    this.notice = flash.notice
    this.alert = flash.alert
  }

  get hasMessage(): boolean {
    return this.notice != null || this.alert != null
  }

  clear() {
    this.notice = undefined
    this.alert = undefined
  }
}
