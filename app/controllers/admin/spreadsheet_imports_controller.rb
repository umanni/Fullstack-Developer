class Admin::SpreadsheetImportsController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  before_action :set_spreadsheet_import, only: :show

  def index
    authorize SpreadsheetImport, :index?
    @spreadsheet_imports = policy_scope(SpreadsheetImport)
      .includes(:user, :spreadsheet_import_row_errors, file_attachment: :blob)
      .order(created_at: :desc)
  end

  def new
    @spreadsheet_import = SpreadsheetImport.new
    authorize @spreadsheet_import
  end

  def create
    @spreadsheet_import = SpreadsheetImport.new(spreadsheet_import_params)
    @spreadsheet_import.user = Current.user
    authorize @spreadsheet_import

    if @spreadsheet_import.save
      redirect_to admin_spreadsheet_import_path(@spreadsheet_import), notice: "Planilha enviada. A importação está sendo processada em segundo plano."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private
    def set_spreadsheet_import
      @spreadsheet_import = SpreadsheetImport.find(params[:id])
      authorize @spreadsheet_import
    end

    def spreadsheet_import_params
      params.expect(spreadsheet_import: [ :file, :has_header ])
    end
end
