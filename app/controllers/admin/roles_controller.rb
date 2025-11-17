class Admin::RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_user

  def update
    @user.update(admin: !@user.admin)
    redirect_to admin_users_path(page: params[:page]), notice: "User role updated."
  end
end

private
