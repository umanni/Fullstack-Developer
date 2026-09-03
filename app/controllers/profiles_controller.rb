class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    @user.destroy!
    redirect_to new_session_path, status: :see_other, notice: "Your account has been deleted."
  end

  private

  def set_user
    @user = Current.user
  end

  def profile_params
    params.require(:user).permit(:full_name, :email_address, :password, :password_confirmation, :avatar_url, :avatar_image)
  end
end
