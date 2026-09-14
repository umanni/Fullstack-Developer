module Admin
  class DashboardsController < ApplicationController
    def show
      authorize! User, "index?"

      render inertia: "Admin/Dashboard", props: {
        stats: -> { Dashboard::Stats.current }
      }
    end
  end
end
