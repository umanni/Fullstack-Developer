class Api::UsersController < ApplicationController
  def show
    user = User.find(params[:id])
    render json: user, status: 200
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :avatar_image, :admin, :password, :password_confirmation)
  end
end
