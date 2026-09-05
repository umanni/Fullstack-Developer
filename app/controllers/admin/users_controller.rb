class Admin::UsersController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  before_action :set_user, only: %i[ edit update destroy toggle_role ]

  def index
    authorize User, :index?
    @users = policy_scope(User).with_attached_avatar.order(:full_name)
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to admin_users_path, notice: "Usuário criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Usuário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "Usuário excluído com sucesso.", status: :see_other
  end

  def toggle_role
    if @user == Current.user
      redirect_to admin_users_path, alert: "Você não pode alterar seu próprio papel (role)."
    else
      @user.update!(role: @user.admin? ? :no_admin : :admin)
      redirect_to admin_users_path, notice: "Papel atualizado com sucesso."
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
      authorize @user
    end

    def user_params
      attrs = params.expect(user: [ :full_name, :email, :password, :password_confirmation, :role, :avatar, :avatar_url ])
      attrs = attrs.except(:password, :password_confirmation) if attrs[:password].blank?
      attrs
    end
end
