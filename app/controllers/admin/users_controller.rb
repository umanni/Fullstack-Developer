class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_user, except: [ :index, :new, :create ]

  def index
    # @users = User.all.order(admin: :desc)
    @users = User.all.order(:id).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path(page: params[:page]), notice: "User created."
    else
      puts @user.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path(page: params[:page]), notice: "User updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path(page: params[:page]), notice: "User deleted."
  end

  private

  def user_params
    attributes = [ :full_name, :email, :password, :password_confirmation, :avatar ]
    user_params = params.expect(user: attributes)

    if action_name == "update"
      if user_params[:password].blank? && user_params[:password_confirmation].blank?
        user_params.delete(:password)
        user_params.delete(:password_confirmation)
      end
    end

    user_params
  end
end
