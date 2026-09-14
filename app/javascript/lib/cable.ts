import { createConsumer, type Consumer } from '@rails/actioncable'

let consumer: Consumer | null = null

/**
 * One cable connection for the whole app. Every createConsumer() opens its own
 * WebSocket and unsubscribing never closes it, so a consumer per component
 * leaves a socket behind each time that component's effect runs.
 */
export const getConsumer = () => (consumer ??= createConsumer())
