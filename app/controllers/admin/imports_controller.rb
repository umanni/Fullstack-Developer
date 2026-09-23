module Admin
  class ImportsController < BaseController
    def index
      @imports = Import.includes(:user).order(created_at: :desc)
    end

    def show
      @import = Import.find(params[:id])
    end

    def new
      @import = Import.new
    end

    def create
      file = params.dig(:import, :spreadsheet)
      unless file.present?
        @import = Import.new
        flash.now[:alert] = "Selecione um arquivo .csv ou .xlsx."
        render :new, status: :unprocessable_entity
        return
      end

      @import = current_user.imports.build(
        filename: file.original_filename,
        status: "pending"
      )
      @import.spreadsheet.attach(file)

      if @import.save
        ProcessImportJob.perform_later(@import.id)
        redirect_to admin_import_path(@import), notice: "Importação enfileirada. O progresso atualiza em tempo real abaixo."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end
end
