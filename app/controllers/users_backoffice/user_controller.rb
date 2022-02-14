class UsersBackoffice::UserController < UsersBackofficeController
  before_action  :user_admin
  before_action :redirect_back

  def redirect_back
    if !user_signed_in?
      redirect_to new_user_session_path
    end
  end

  def show
  end

  def user_admin
    if current_user.admin == true
      redirect_to users_backoffice_admin_index_path
    end
  end
end
