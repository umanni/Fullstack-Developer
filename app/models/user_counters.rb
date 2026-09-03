# The single place that knows how the dashboard numbers are computed and
# broadcast. Keeping it here means one after_commit hook on User instead of
# callbacks scattered across the controllers that happen to change a role.
class UserCounters
  STREAM = "admin_user_counters".freeze
  TARGET = "user-counters".freeze

  attr_reader :admins, :users

  def initialize(counts_by_role)
    @admins = counts_by_role.fetch("admin", 0)
    @users = counts_by_role.fetch("user", 0)
  end

  def total
    admins + users
  end

  class << self
    def current
      new(User.role_counts)
    end

    # One stream per locale: the broadcast carries rendered HTML, and the
    # labels inside it are translated, so a single stream would push one
    # language to everyone watching.
    def stream_for(locale)
      "#{STREAM}:#{locale}"
    end

    def broadcast
      return if suspended?

      counters = current

      User::SUPPORTED_LOCALES.each do |locale|
        I18n.with_locale(locale) do
          Turbo::StreamsChannel.broadcast_replace_to(
            stream_for(locale),
            target: TARGET,
            partial: "admin/dashboard/counters",
            locals: { counters: counters }
          )
        end
      end
    end

    # Importing a spreadsheet would otherwise broadcast once per row. The job
    # wraps its work in this and broadcasts once when it finishes.
    def suspend_broadcasts
      previous = Thread.current[:user_counters_suspended]
      Thread.current[:user_counters_suspended] = true
      yield
    ensure
      Thread.current[:user_counters_suspended] = previous
    end

    def suspended?
      Thread.current[:user_counters_suspended].present?
    end
  end
end
