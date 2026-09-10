# frozen_string_literal: true

# Cleans up expired sessions to prevent unbounded session accumulation.
# Sessions older than 30 days are destroyed.
class ExpireSessionsJob < ApplicationJob
  queue_as :default

  SESSION_TTL = 30.days
  BATCH_SIZE = 1_000

  def perform
    count = Session.expired.in_batches(of: BATCH_SIZE).sum(&:delete_all)
    Rails.logger.info("[ExpireSessionsJob] removed #{count} expired sessions") if count.positive?
    count
  end
end
