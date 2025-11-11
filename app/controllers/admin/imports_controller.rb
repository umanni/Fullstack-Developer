class Admin::ImportsController < ApplicationController
  before_action :ensure_admin!
  before_action :set_import, only: [ :show ]

  def index
    @imports = Import.includes(:user)
                     .recent
                     .page(params[:page])
                     .per(10)
    @pending_imports = Import.where(status: "pending").count
    @processing_imports = Import.where(status: "processing").count
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: import_json }
    end
  end

  def create
    @import = current_user.imports.build

    if params[:file].present?
      @import.file.attach(params[:file])
      @import.file_name = params[:file].original_filename

      if @import.save
        UserImportJob.perform_later(@import)

        redirect_to admin_import_path(@import),
                    notice: "Import started successfully. Processing will begin shortly."
      else
        redirect_to admin_imports_path,
                    alert: "Import failed: #{@import.errors.full_messages.join(', ')}"
      end
    else
      redirect_to admin_imports_path, alert: "Please select a file to import."
    end
  end

  private

  def set_import
    @import = Import.find(params[:id])
  end

  def import_json
    {
      id: @import.id,
      status: @import.status,
      progress: @import.progress,
      total_rows: @import.total_rows,
      processed_rows: @import.processed_rows,
      successful_rows: @import.successful_rows,
      failed_rows: @import.failed_rows,
      success_rate: @import.success_rate,
      estimated_time_remaining: @import.estimated_time_remaining,
      created_at: @import.created_at,
      updated_at: @import.updated_at
    }
  end
end
