class ProfilesController < ApplicationController
  def show
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Profile deleted."
  end

  private
    def profile_params
      params.expect(user: [ :full_name, :email, :avatar_image ])
    end
end
