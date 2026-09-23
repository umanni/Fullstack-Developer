class Api::V1::UsersController < Api::V1::BaseController
  def index
    users = User.all
    render json: UserSerializer.new(users).serializable_hash
  end

  def show
    user = User.find(params[:id])
    render json: UserSerializer.new(user).serializable_hash
  end

  def create
    user = User.new(user_params)
    user.user_role ||= UserRole.non_admin
    if user.save
      render json: UserSerializer.new(user).serializable_hash, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: UserSerializer.new(user).serializable_hash
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head :no_content
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :avatar_url, :avatar_image)
  end
end
