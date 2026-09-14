module DashboardBroadcasts
  KEY = :suppress_dashboard_broadcasts

  def self.suppressed?
    ActiveSupport::IsolatedExecutionState[KEY].present?
  end

  def self.suppress
    previous = ActiveSupport::IsolatedExecutionState[KEY]
    ActiveSupport::IsolatedExecutionState[KEY] = true
    yield
  ensure
    ActiveSupport::IsolatedExecutionState[KEY] = previous
  end
end
