module Admin
  class UserImportsController < BaseController
    def index
      @user_imports = UserImport.recent_first.includes(file_attachment: :blob).limit(25)
      @user_import = UserImport.new
    end

    def show
      @user_import = UserImport.find(params.expect(:id))
      @row_errors = @user_import.row_errors.order(:row_number)
    end

    def new
      @user_import = UserImport.new
    end

    def create
      @user_import = UserImport.new(user_import_params.merge(administrator: Current.user))

      if @user_import.save
        # Enqueued here rather than from a model callback: creating a record in
        # a test or a console should not quietly start a worker.
        ProcessUserImportJob.perform_later(@user_import.id)
        redirect_to admin_user_import_path(@user_import), notice: t(".scheduled")
      else
        @user_imports = UserImport.recent_first.limit(25)
        render :index, status: :unprocessable_content
      end
    end

    # The blank spreadsheet, with the expected header and instructions written
    # into it as comment rows the importer skips.
    def template
      send_data UserImportTemplate.to_csv,
                filename: "user-import-template.csv",
                type: "text/csv; charset=utf-8",
                disposition: "attachment"
    end

    # The rejected rows as a spreadsheet, so an operator can fix them next to
    # the original file.
    def rejected_rows
      import = UserImport.find(params.expect(:id))

      send_data UserImportTemplate.rejected_rows_csv(import),
                filename: "user-import-#{import.id}-rejected-rows.csv",
                type: "text/csv; charset=utf-8",
                disposition: "attachment"
    end

    private

    def user_import_params
      params.expect(user_import: [:file])
    end
  end
end
