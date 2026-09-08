module Admin
  class DashboardController < BaseController
    def show
      recent_imports = UserImport.includes(:uploaded_by, spreadsheet_attachment: :blob).order(created_at: :desc).limit(5)

      render inertia: "Admin/Dashboard", props: {
        statistics: UserStatistics.call,
        recent_imports: recent_imports.map { |user_import| UserImportPresenter.new(user_import).as_json }
      }
    end
  end
end
