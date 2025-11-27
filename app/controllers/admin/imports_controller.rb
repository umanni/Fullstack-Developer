class Admin::ImportsController < Admin::BaseController
  before_action :set_import, only: [:show, :status]

  def index
    @imports = policy_scope(UserImport).recent.includes(:user)
    authorize UserImport
  end

  def new
    @import = UserImport.new
    authorize @import
  end

  def create
    @import = UserImport.new(import_params.merge(user: current_user))
    authorize @import

    if @import.save
      UserImportJob.perform_later(@import.id)
      redirect_to admin_import_path(@import), notice: 'Import started. Progress will be shown below.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @import
  end

  def status
    authorize @import

    render json: {
      status: @import.status,
      progress: @import.progress_percentage,
      processed_rows: @import.processed_rows,
      total_rows: @import.total_rows,
      success_count: @import.success_count,
      error_count: @import.error_count,
      errors: @import.error_messages
    }
  end

  private

  def set_import
    @import = UserImport.find(params[:id])
  end

  def import_params
    params.require(:user_import).permit(:spreadsheet_file)
  end
end

