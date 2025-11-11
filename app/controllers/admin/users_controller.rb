class Admin::UsersController < ApplicationController
  before_action :ensure_admin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :toggle_role ]

  def index
    @users = User.with_attached_avatar_image.order(:created_at)
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.where("full_name ILIKE ? OR email ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    @users = @users.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = SecureRandom.hex(8) if @user.password.blank?

    if @user.save
      UserMailer.welcome_email(@user, @user.password).deliver_later if Rails.env.production?
      redirect_to admin_user_path(@user), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    user_update_params = user_params
    user_update_params.delete(:password) if user_update_params[:password].blank?

    if @user.update(user_update_params)
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete your own account."
      return
    end

    @user.destroy
    redirect_to admin_users_path, notice: "User was successfully deleted."
  end

  def toggle_role
    new_role = @user.admin? ? "user" : "admin"

    if @user == current_user && new_role == "user"
      redirect_to admin_users_path, alert: "You cannot remove admin access from your own account."
      return
    end

    @user.update(role: new_role)
    redirect_to admin_users_path, notice: "User role updated to #{new_role.humanize}."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :role, :avatar_url, :avatar_image)
  end
end
