class UsersBackoffice::AdminController < UsersBackofficeController
  before_action  :user_admin
  before_action :set_user, only: [:destroy]
  before_action :redirect_back

  def redirect_back
    if !user_signed_in?
      redirect_to new_user_session_path
    end
  end
  
  def index
    @users = User.all.page(params[:page]).per(25)
  end

  def show
  end

  def import_users
  end

  def import
    User.import(params[:file])
    redirect_to users_backoffice_admin_index_path, notice: "Usuários cadastrados"
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_backoffice_admin_index_path, notice: 'Usuario deletado' }
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
        redirect_to users_backoffice_user_show_path
      end
    end
end
