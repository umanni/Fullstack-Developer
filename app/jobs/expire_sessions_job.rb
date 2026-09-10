# frozen_string_literal: true

# Cleans up expired sessions to prevent unbounded session accumulation.
# Sessions older than 30 days are destroyed.
class ExpireSessionsJob < ApplicationJob
  queue_as :default

  SESSION_TTL = 30.days

  def perform
    expired = Session.where("last_active_at < ?", SESSION_TTL.ago)
    count = expired.count
    expired.delete_all
    Rails.logger.info("[ExpireSessionsJob] removed #{count} expired sessions") if count.positive?
    count
  end
end
