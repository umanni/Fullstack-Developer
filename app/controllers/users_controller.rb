class UsersController < ApplicationController
  before_action :set_user
  before_action :ensure_user_or_admin!

  def show
  end

  def edit
  end

  def update
    user_update_params = user_params
    user_update_params.delete(:password) if user_update_params[:password].blank?

    if @user.update(user_update_params)
      redirect_to profile_path, notice: "Profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      @user.destroy
      redirect_to root_path, notice: "Your account has been successfully deleted."
    else
      redirect_to profile_path, alert: "You can only delete your own account."
    end
  end

  private

  def set_user
    @user = current_user
  end

  def ensure_user_or_admin!
    redirect_to root_path, alert: "Access denied." unless current_user == @user || current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :avatar_url, :avatar_image)
  end
end
