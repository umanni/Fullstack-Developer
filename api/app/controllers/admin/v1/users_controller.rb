module Admin::V1
  class UsersController < ApiController
    before_action :load_user, only: [:update, :destroy]
    skip_before_action :restrict_access_for_admin!, only: [:update, :destroy]

    def index
      @users = User.where.not(id: @current_user.id)
      render json: @users
    end

    def create
      @user = User.new
      @user.attributes = user_params
      save_user!
    end

    def update
      @user.attributes = user_params
      save_user!
    end

    def destroy
      @user.destroy
    rescue
      render_error(fields: @user.messages)
    end

    private

    def load_user
      @user = User.find(params[:id])
    end

    def user_params
      return {} unless params.has_key?(:user)
      params.require(:user).permit(
        :id, :first_name, :last_name, :image, :email, :password, :password_confirmation, :profile)
    end

    def save_user!
      @user.save!
      render json: @user, status: :ok
    rescue
      render_error(fields: @user.errors.messages)
    end
  end
end