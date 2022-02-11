class UsersBackoffice::UserController < UsersBackofficeController
  before_action  :user_admin

  def index
  end

  def user_admin
    if current_user.admin == true
      redirect_to users_backoffice_admin_index_path
    end
  end
end
