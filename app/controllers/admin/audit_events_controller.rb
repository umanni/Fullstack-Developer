module Admin
  # The record of what administrators did. Read only, by design: a trail that
  # can be edited from the interface it records is not a trail.
  class AuditEventsController < BaseController
    include Paginating

    def index
      @pagy, @audit_events = paginate(
        AuditEvent.recent_first.includes(:actor, :subject), default_limit: 25
      )
    end
  end
end
