class Api::UsersController < ApplicationController
  def index
    users = User.all()
    render json: users, status: 200
  end

  def show
    user = User.find(params[:id])
    render json: user, status: 200
  end

  def create
    user = User.new(user_params)
    user.save
    render json: user, status: 200
  end

  def update
    user = User.find(params[:id])
    user.update(user_params)

    render json: user, status: 200
  end

  def destroy
    User.delete(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :avatar_image, :admin, :password, :password_confirmation)
  end
end
