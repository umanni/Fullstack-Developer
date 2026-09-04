class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params.merge(role: :member))

    if @user.save
      start_new_session_for @user
      redirect_to profile_path, notice: "Welcome! Your account was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:full_name, :email_address, :password, :password_confirmation, :avatar_url, :avatar_image)
  end
end
