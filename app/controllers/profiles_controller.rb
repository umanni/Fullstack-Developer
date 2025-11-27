class ProfilesController < ApplicationController
  before_action :set_user

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    current_password = params[:user][:current_password]
    password_changed = params[:user][:password].present?
    email_changed = params[:user][:email] != @user.email

    if password_changed || email_changed
      if current_password.blank?
        @user.errors.add(:current_password, 'is required to change password or email')
        render :edit, status: :unprocessable_entity
        return
      end

      unless @user.valid_password?(current_password)
        @user.errors.add(:current_password, 'is incorrect')
        render :edit, status: :unprocessable_entity
        return
      end
    end

    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    update_params = user_params.except(:current_password)

    if @user.update(update_params)
      redirect_to profile_path, notice: 'Profile updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user

    @user.destroy
    sign_out @user
    redirect_to root_path, notice: 'Your account has been deleted successfully.'
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :avatar_url, :avatar_image, :password, :password_confirmation, :current_password)
  end
end
