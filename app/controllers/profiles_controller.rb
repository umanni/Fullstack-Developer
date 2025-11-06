class ProfilesController < ApplicationController
  before_action :set_user_profile

  def show
    authorize @user_profile
  end

  def edit
    authorize @user_profile
  end

  def update
    authorize @user_profile

    params_to_update = profile_params

    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user_profile.update(params_to_update)
      bypass_sign_in(@user_profile) if params_to_update[:password].present?
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_profile
    @user_profile = current_user
  end

  def profile_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :avatar_image, :avatar_url)
  end
end
