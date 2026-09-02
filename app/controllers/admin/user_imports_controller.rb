module Admin
  class UserImportsController < BaseController
    def index
      @user_imports = UserImport.recent_first.with_attached_spreadsheet.includes(:created_by).limit(50)
    end

    def new
      @user_import = UserImport.new
    end

    def create
      @user_import = UserImport.new(created_by: Current.user, spreadsheet: import_params[:spreadsheet])

      if @user_import.save
        Imports::ProcessJob.perform_later(@user_import)
        redirect_to admin_user_import_path(@user_import), notice: "Import queued for background processing."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @user_import = UserImport.with_attached_spreadsheet.includes(:created_by, rows: :user).find(params[:id])
    end

    private
      def import_params
        params.expect(user_import: %i[ spreadsheet ])
      end
  end
end
