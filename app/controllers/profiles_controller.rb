class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: "Perfil atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    cookies.delete(:session_id)
    redirect_to new_session_path, notice: "Sua conta foi excluída.", status: :see_other
  end

  private
    def set_user
      @user = Current.user
      authorize @user
    end

    def user_params
      attrs = params.expect(user: [ :full_name, :email, :password, :password_confirmation, :avatar, :avatar_url ])
      attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
      attrs
    end
end
