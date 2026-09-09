module Admin
  class UserImportsController < BaseController
    def index
      render inertia: "Admin/Imports/Index", props: {
        imports: UserImport.order(created_at: :desc).as_json(only: [ :id, :status, :total_rows, :processed_rows, :failed_rows ])
      }
    end

    def new
      @import = UserImport.new
      render inertia: "Admin/Imports/New"
    end

    def create
      @import = UserImport.new
      @import.file.attach(params.expect(user_import: [ :file ])[:file])
      if @import.file.attached? && @import.save
        UserImportJob.perform_later(@import)
        redirect_to admin_user_import_path(@import), notice: "Import started."
      else
        render inertia: "Admin/Imports/New", status: :unprocessable_entity
      end
    end

    def show
      @import = UserImport.find(params[:id])
      render inertia: "Admin/Imports/Show", props: {
        import: @import.as_json(only: [ :id, :status, :total_rows, :processed_rows, :failed_rows ])
      }
    end
  end
end
