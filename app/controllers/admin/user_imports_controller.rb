module Admin
  class UserImportsController < BaseController
    before_action :set_user_import, only: :show

    def index
      imports = UserImport.includes(:uploaded_by, spreadsheet_attachment: :blob).order(created_at: :desc).limit(50)

      render inertia: "Admin/Imports/Index", props: {
        imports: imports.map { |user_import| UserImportPresenter.new(user_import).as_json }
      }
    end

    def new
      render inertia: "Admin/Imports/New"
    end

    def create
      user_import = Current.user.uploaded_user_imports.new(user_import_params)

      if user_import.save
        ProcessUserImportJob.perform_later(user_import)
        redirect_to admin_user_import_path(user_import), notice: "Import queued successfully."
      else
        redirect_to new_admin_user_import_path, inertia: { errors: user_import.errors }
      end
    end

    def show
      render inertia: "Admin/Imports/Show", props: {
        user_import: UserImportPresenter.new(@user_import, include_errors: true).as_json
      }
    end

    private
      def set_user_import
        @user_import = UserImport.includes(:uploaded_by, spreadsheet_attachment: :blob).find(params[:id])
      end

      def user_import_params
        params.expect(user_import: [ :spreadsheet ])
      end
  end
end
