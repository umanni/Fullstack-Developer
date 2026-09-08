declare module '@rails/actioncable' {
  export interface Subscription {
    unsubscribe(): void
    connected(): void
  }

  export interface Subscriptions {
    create<Params extends Record<string, unknown>>(
      channel: Params,
      mixin?: {
        received?: (payload: unknown) => void
      },
    ): Subscription
  }

  export interface Consumer {
    subscriptions: Subscriptions
  }

  export function createConsumer(url?: string): Consumer
}
