module Admin
  class DashboardController < BaseController
    def show
      @counters = UserCounters.current
    end
  end
end
