# The dashboard stream carries administrative data, so subscribing to it is
# checked in its own right. The connection already refuses anyone without a
# session; this refuses anyone who is signed in but not an administrator, so a
# leaked stream name is not enough on its own.
class AdminCountersChannel < Turbo::StreamsChannel
  def subscribed
    return reject unless current_user&.admin?

    super
  end
end
