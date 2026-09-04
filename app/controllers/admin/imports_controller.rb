module Admin
  class ImportsController < BaseController
    def index
      @imports = UserImport.includes(:created_by).order(created_at: :desc)
      @import = UserImport.new
    end

    def create
      @import = Current.user.created_imports.new(import_params)

      if @import.save
        redirect_to admin_imports_path, notice: "Import started. Progress will update live."
      else
        @imports = UserImport.includes(:created_by).order(created_at: :desc)
        render :index, status: :unprocessable_entity
      end
    end

    def show
      @import = UserImport.find(params[:id])
    end

    private

    def import_params
      params.require(:user_import).permit(:spreadsheet)
    end
  end
end
