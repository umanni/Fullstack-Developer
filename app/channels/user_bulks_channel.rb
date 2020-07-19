class UserBulksChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_bulks_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end