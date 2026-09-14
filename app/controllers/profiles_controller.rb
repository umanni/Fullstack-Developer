class ProfilesController < ApplicationController
  before_action :set_profile

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      revoke_other_sessions_for @user
      redirect_to profile_path, notice: "Your profile was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @user.destroy
      terminate_session
      redirect_to new_session_path, notice: "Your account has been deleted.", status: :see_other
    else
      redirect_to profile_path, alert: @user.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_profile
      @user = Current.user
    end

    def profile_params
      without_untouched_fields params.expect(
        user: [ :full_name, :email, :password, :password_confirmation, :avatar_image, :remove_avatar_image ]
      )
    end
end
