module Admin
  class DashboardController < BaseController
    def show
      @stats = Dashboard::Stats.call
      @recent_imports = UserImport.recent_first.with_attached_spreadsheet.limit(5)
    end
  end
end
