module Admin
  class UserImportsController < BaseController
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to admin_user_imports_path, alert: "Try again later." }

    def index
      imports = UserImport.order(created_at: :desc).page(params[:page]).per(25)
      render inertia: "Admin/Imports/Index", props: {
        imports: imports.map { |imp|
          imp.as_json(only: [ :id, :status, :total_rows, :processed_rows, :failed_rows ]).merge(
            file_name: imp.file.attached? ? imp.file.filename.to_s : nil
          )
        },
        pagination: {
          current_page: imports.current_page,
          total_pages: imports.total_pages,
          total_count: imports.total_count
        }
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
        AuditLog.log!(action: "import_created", user: Current.user, auditable: @import, metadata: { file_name: @import.file.filename.to_s }, request: request)
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
          progress_percent: @import.progress_percent,
          errors_truncated: @import.row_errors.size >= 100
        )
      }
    end
  end
end
