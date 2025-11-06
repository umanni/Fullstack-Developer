class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :toggle_role ]

  def index
    @users = policy_scope(User)
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to admin_user_path(@user), notice: "User created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    # Use the same password-blank-check from the profiles controller
    params_to_update = user_params
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user.update(params_to_update)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  # Our custom action
  def toggle_role
    authorize @user, :toggle_role? # Specific policy check

    if @user.admin?
      @user.user! # Toggles to user
    else
      @user.admin! # Toggles to admin
    end

    redirect_to admin_users_path, notice: "User role updated."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email,
      :password,
      :password_confirmation,
      :role,
      :avatar_image,
      :avatar_url
    )
  end
end
