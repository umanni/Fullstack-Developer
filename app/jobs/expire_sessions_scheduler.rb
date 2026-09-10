# frozen_string_literal: true

# Periodically clean up expired sessions.
# Solid Queue runs this via the solid_queue-scheduler or inline in Puma.
# Schedule: once daily at 3 AM UTC.
class ExpireSessionsScheduler < SolidQueue::Scheduler
  schedule "expire_sessions", class: "ExpireSessionsJob", cron: "0 3 * * *"
end
