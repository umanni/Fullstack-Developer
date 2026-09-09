import { createConsumer } from "@rails/actioncable"

let consumer = null

export function cable() {
  if (!consumer) consumer = createConsumer()
  return consumer
}

export function subscribe(channel, params, received) {
  return cable().subscriptions.create({ channel, ...params }, { received })
}
