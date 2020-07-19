class BroadcastUserBulksDataJob < ApplicationJob
  queue_as :broadcast_user_bulks_data

  def perform
    user_bulks = UserBulk.all
    ActionCable.server.broadcast(
      "user_bulks_channel",
      user_bulks: user_bulks)

    BroadcastUserBulksDataJob.set(wait: 10.seconds).perform_later
  end
end
