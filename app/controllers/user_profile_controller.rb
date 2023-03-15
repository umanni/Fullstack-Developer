class UserProfileController < ApplicationController
  before_action :authenticate_user!

  def show 
    if current_user.user_profile
      @user_profile = current_user.user_profile
    else
      redirect_to edit_user_profile_path(current_user), alert: 'Please complete your profile'
    end
  end

  def edit
    @user_profile = current_user.user_profile || current_user.build_user_profile
  end
end
