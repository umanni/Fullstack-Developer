# Every administrative stream -- the dashboard counters and the progress of a
# running import -- carries administrative data, so subscribing is
# checked in its own right. The connection already refuses anyone without a
# session; this refuses anyone who is signed in but not an administrator, so a
# leaked stream name is not enough on its own.
class AdminStreamChannel < Turbo::StreamsChannel
  def subscribed
    return reject unless current_user&.admin?

    super
  end
end
