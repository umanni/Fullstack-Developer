module Admin
  class DashboardController < BaseController
    def show
      @stats = Users::DashboardStats.call
      @recent_imports = UserImport.includes(:created_by).order(created_at: :desc).limit(5)
    end
  end
end
