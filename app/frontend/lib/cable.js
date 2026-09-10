import { createConsumer } from "@rails/actioncable"

let consumer = null

export function cable() {
  if (!consumer) consumer = createConsumer()
  return consumer
}

/**
 * Subscribe to an ActionCable channel.
 * @param {string} channel - Channel class name
 * @param {object} params - Subscription params (e.g. { id: 1 })
 * @param {object} callbacks - { received, connected, disconnected }
 * @returns {object} subscription
 */
export function subscribe(channel, params, callbacks) {
  const { received, connected, disconnected } = typeof callbacks === "function"
    ? { received: callbacks, connected: undefined, disconnected: undefined }
    : callbacks

  return cable().subscriptions.create(
    { channel, ...params },
    {
      received,
      connected() {
        if (connected) connected()
      },
      disconnected() {
        if (disconnected) disconnected()
      },
    },
  )
}
