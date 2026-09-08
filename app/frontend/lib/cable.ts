import { createConsumer, type Consumer } from '@rails/actioncable'

let consumer: Consumer | undefined

export function cable() {
  consumer ??= createConsumer()
  return consumer
}

export function disconnectCable() {
  consumer?.disconnect()
  consumer = undefined
}
