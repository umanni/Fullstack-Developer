module Admin
  class UsersController < ApplicationController
    include Authorizable
    before_action :require_admin!

    def index
      @users = if params[:query].present?
                User.where("full_name ILIKE :query OR email ILIKE :query", query: "%#{params[:query]}%")
                    .order(:full_name)
              else
                User.all.order(:full_name)
              end
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: 'Usuário criado com sucesso'
      else
        flash.now[:alert] = 'Usuário não pôde ser criado'
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'Usuário atualizado com sucesso'
      else
        flash.now[:alert] = 'Usuário não pôde ser atualizado'
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to admin_users_path, notice: 'Usuário excluído com sucesso'
    end

    def toggle_role
      @user = User.find(params[:id])

      if @user.admin?
        @user.user!
      else
        @user.admin!
      end

      redirect_to admin_users_path, notice: 'Função do usuário atualizada com sucesso'
    end

    private

    def user_params
      params.require(:user).permit(:full_name, :email, :password, :role)
    end
  end
end
