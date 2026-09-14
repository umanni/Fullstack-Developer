module Admin
  class SpreadsheetImportsController < BaseController
    before_action :set_spreadsheet_import, only: :show

    def index
      @spreadsheet_imports = SpreadsheetImport.recent_first.includes(:user, file_attachment: :blob)
    end

    def new
      @spreadsheet_import = SpreadsheetImport.new
    end

    def create
      @spreadsheet_import = Current.user.spreadsheet_imports.new(spreadsheet_import_params)

      if @spreadsheet_import.save
        SpreadsheetImportJob.perform_later(@spreadsheet_import)
        redirect_to admin_spreadsheet_import_path(@spreadsheet_import)
      else
        render :new, status: :unprocessable_content
      end
    end

    def show
    end

    private
      def set_spreadsheet_import
        @spreadsheet_import = SpreadsheetImport.find(params[:id])
      end

      def spreadsheet_import_params
        permitted = params.expect(spreadsheet_import: [ :file ])
        permitted[:file].is_a?(ActionDispatch::Http::UploadedFile) ? permitted : permitted.except(:file)
      end
  end
end
