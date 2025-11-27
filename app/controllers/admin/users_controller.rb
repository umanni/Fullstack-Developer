class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_role]

  def index
    @users = policy_scope(User).includes(:avatar_image_attachment).order(created_at: :desc)
    authorize User
  end

  def show
    authorize @user
    redirect_to admin_users_path
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to admin_users_path, notice: 'User created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(user_params)
      redirect_to admin_users_path, notice: 'User updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user

    if @user == current_user
      redirect_to admin_users_path, alert: 'You cannot delete your own account from here.'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'User deleted successfully.'
    end
  end

  def toggle_role
    if @user == current_user
      redirect_to admin_users_path, alert: 'You cannot change your own role.'
      return
    end

    authorize @user, :toggle_role?

      new_role = @user.admin? ? :user : :admin
      @user.update(role: new_role)
      redirect_to admin_users_path, notice: "User role changed to #{new_role}."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :role, :avatar_url, :avatar_image)
  end
end

