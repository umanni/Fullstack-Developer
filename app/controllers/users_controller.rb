class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :authorize_user!

  def show
  end

  private

  def authorize_user!
    unless current_user.admin? || current_user == @user
      redirect_to root_path, alert: "Access denied."
    end
  end
end
