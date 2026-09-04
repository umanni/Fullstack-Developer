module Admin
  # The record of what administrators did. Read only, by design: a trail that
  # can be edited from the interface it records is not a trail.
  class AuditEventsController < BaseController
    include Pagy::Backend

    def index
      @pagy, @audit_events = pagy(
        AuditEvent.recent_first.includes(:actor, :subject), limit: 25
      )
    end
  end
end
