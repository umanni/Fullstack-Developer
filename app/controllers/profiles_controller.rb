class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :ensure_correct_user, only: %i[show edit update destroy]

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Perfil atualizado com sucesso'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: 'Conta excluída com sucesso.'
  end

  private

  def set_user
    @user = User.find(params[:id]) if params[:id]
    @user ||= current_user
  end

  def ensure_correct_user
    unless @user == current_user
      redirect_to root_path, alert: 'Acesso não autorizado'
    end
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :avatar)
  end
end
