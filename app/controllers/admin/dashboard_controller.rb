# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      overview = Dashboard::TotalsQuery.call(User.all)

      render inertia: "Admin/Dashboard", props: {
        overview: overview.to_inertia,
        urls: { users_url: admin_users_path, imports_url: admin_user_imports_path }
      }
    end
  end
end
