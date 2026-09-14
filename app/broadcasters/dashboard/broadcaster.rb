# app/broadcasters/dashboard/broadcaster.rb
module Dashboard
  class Broadcaster
    STREAM       = "dashboard:stats"
    LEADING_KEY  = "dashboard/stats/leading"
    TRAILING_KEY = "dashboard/stats/trailing"
    WINDOW       = 1.second

    class << self
      def call
        Stats.expire
        claim(LEADING_KEY) ? broadcast : schedule_trailing
      end

      def broadcast
        ActionCable.server.broadcast(STREAM, { type: "stats.changed" })
      end

      private

      def schedule_trailing
        return unless claim(TRAILING_KEY)

        Dashboard::BroadcastJob.set(wait: WINDOW).perform_later
      end

      # `unless_exist` makes this an atomic claim: the first caller in the window
      # gets true, everyone after it gets false until the key expires.
      def claim(key)
        Rails.cache.write(key, true, expires_in: WINDOW, unless_exist: true)
      end
    end
  end
end
