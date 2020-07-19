class UserBulkJob < ApplicationJob
  queue_as :user_bulks

  def perform(user_bulk_id)
    user_bulk = UserBulk.find(user_bulk_id)
    user_bulk.process_bulk!
  end
end