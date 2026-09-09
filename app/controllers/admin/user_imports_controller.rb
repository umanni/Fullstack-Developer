module Admin
  class UserImportsController < BaseController
    def index
      @imports = UserImport.order(created_at: :desc)
    end

    def new
      @import = UserImport.new
    end

    def create
      @import = UserImport.new
      @import.file.attach(params.expect(user_import: [ :file ])[:file])
      if @import.file.attached? && @import.save
        UserImportJob.perform_later(@import)
        redirect_to admin_user_import_path(@import), notice: "Import started."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @import = UserImport.find(params[:id])
    end
  end
end
