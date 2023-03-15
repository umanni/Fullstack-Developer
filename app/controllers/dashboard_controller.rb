class DashboardController < ApplicationController
  def index
    @total_users = User.count
    @users_by_role = User.group(:role).count
  end

  def list_users
    @users = User.all
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
  
  def user_bulk_params
    if params[:user_bulk].present?
      params.require(:user_bulk).permit(:csv_file)
    else
      {}
    end
  end

end
