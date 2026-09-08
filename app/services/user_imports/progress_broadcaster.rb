# frozen_string_literal: true

module UserImports
  # The single place that broadcasts import progress (DRY — Fase 6 will feed
  # the Inertia front end with this same payload). Injected into the
  # Processor as the real default; tests replace it with a fake (DIP).
  class ProgressBroadcaster
    def call(user_import)
      ActionCable::Channel::Base.broadcast_to(user_import, payload(user_import))
    end

    private

    def payload(user_import)
      {
        id: user_import.id,
        status: user_import.status,
        total: user_import.total_rows,
        processed: user_import.processed_rows,
        failed: user_import.failed_rows,
        percent: user_import.progress
      }
    end
  end
end
