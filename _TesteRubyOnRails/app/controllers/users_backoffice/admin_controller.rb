class UsersBackoffice::AdminController < UsersBackofficeController
  before_action  :user_admin
  before_action :set_user, only: [:destroy]
  
  def index
    @users = User.all
  end

  def import
    User.import(params[:file])
    redirect_to users_backoffice_admin_index_path, notice: "Usuarios criados"
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_backoffice_admin_index_path, notice: 'Mining type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_admin
      if current_user.admin == false
        redirect_to users_backoffice_user_index_path
      end
    end
end
