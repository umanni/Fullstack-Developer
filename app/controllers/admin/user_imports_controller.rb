module Admin
  class UserImportsController < BaseController
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to admin_user_imports_path, alert: "Try again later." }

    def index
      imports = UserImport.order(created_at: :desc).map do |imp|
        imp.as_json(only: [ :id, :status, :total_rows, :processed_rows, :failed_rows ]).merge(
          file_name: imp.file.attached? ? imp.file.filename.to_s : nil
        )
      end
      render inertia: "Admin/Imports/Index", props: { imports: imports }
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
        import: @import.as_json(only: [ :id, :status, :total_rows, :processed_rows, :failed_rows, :row_errors ]).merge(
          progress_percent: @import.progress_percent
        )
      }
    end
  end
end
