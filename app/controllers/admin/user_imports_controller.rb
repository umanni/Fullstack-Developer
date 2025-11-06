class Admin::UserImportsController < Admin::BaseController
  def new
    @user_import = UserImport.new
  end

  def create
    @user_import = UserImport.new(user_import_params)

    if @user_import.save
      ImportUsersJob.perform_later(@user_import)

      redirect_to admin_user_import_path(@user_import), notice: "Import started."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user_import = UserImport.find(params[:id])
  end

  private

  def user_import_params
    params.require(:user_import).permit(:file)
  end
end
