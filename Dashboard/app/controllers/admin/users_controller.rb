class Admin::UsersController < ApplicationController
  def index
    @users = User.all
    @count = User.count
    @admin = User.where(admin: 'true').count
    @noadmin = User.where.not(admin: 'true').count
  end
end
