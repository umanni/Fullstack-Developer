class Api::MainController < ApplicationController
  def index
    result = {current_user: current_user.as_json(only: [:id, :full_name, :email, :avatar_image, :admin, :created_at])}
    render json: result, status: 200
  end
end
