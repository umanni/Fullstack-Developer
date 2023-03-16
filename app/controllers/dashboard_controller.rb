class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show_user_profile]
  # Use a before_action to set the @user instance variable for the show_user_profile action

  def index
    @total_users = User.count
    @users_by_role = User.group(:role).count
  end

  def list_users
    @users = User.all
  end

  def show_user_profile
  end

  def new_user
    @user = User.new
  end
  
  def create_user
    upload_avatar_image

    @user = User.new(user_params)

    if @user.save
      redirect_to dashboard_path, notice: 'User was successfully created.'
    else
      redirect_to dashboard_path, alert: 'User was not created.'
    end
  end

  def new_user_bulk
    @user_bulk = UserBulk.new
  end

  def create_user_bulk
    @user_bulk = UserBulk.new(user_bulk_params)

    if @user_bulk.csv_file.blank?
      redirect_back(fallback_location: new_user_bulk_path, alert: 'Please select a file to upload')
    else
      if @user_bulk.save
        @user_bulk.process_csv_file!
        redirect_to dashboard_path, notice: 'CSV file imported successfully!'
      else
        render :new_user_bulk
      end
    end
  end

  private

  def upload_avatar_image
    avatar_image = params[:user][:avatar_image]
    if avatar_image.present?
      uploader = AvatarImageUploader.new
      uploader.store!(avatar_image)
      params[:user][:avatar_image] = uploader.url
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :full_name, :role, :password, :avatar_image)
  end

  def user_bulk_params
    params.require(:user_bulk).permit(:csv_file)
  end
end
