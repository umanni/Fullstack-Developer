module Admin
  class DashboardsController < BaseController
    def show
      @stats = User.dashboard_stats
      @recent_imports = Import.order(created_at: :desc).limit(5)
    end
  end
end
