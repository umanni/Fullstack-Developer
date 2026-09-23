class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.user_role = UserRole.non_admin

    if @user.save
      start_new_session_for @user
      redirect_to profile_path, notice: "Conta criada com sucesso. Bem-vindo!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(
      :full_name,
      :email,
      :password,
      :password_confirmation,
      :avatar_url,
      :avatar_image
    )
  end
end
