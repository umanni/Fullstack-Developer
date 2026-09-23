class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Perfil atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    @user.destroy!
    redirect_to new_session_path, notice: "Sua conta foi excluída.", status: :see_other
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
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
