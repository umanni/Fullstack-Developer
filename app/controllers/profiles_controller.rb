class ProfilesController < ApplicationController
  def show
    @user = Current.user
    render inertia: "Profile/Show", props: { user: profile_json(@user) }
  end

  def edit
    @user = Current.user
    render inertia: "Profile/Edit", props: { user: profile_json(@user) }
  end

  def update
    @user = Current.user
    if @user.update(profile_params_without_stale_avatar)
      # An explicit URL wins over a stored upload; drop the now-unused file
      # only after the record is safely persisted.
      @user.avatar_image.purge if replacing_attachment_with_url?
      redirect_to profile_path, notice: "Profile updated."
    else
      render inertia: "Profile/Edit", props: { user: profile_json(@user) }, status: :unprocessable_entity
    end
  end

  def remove_avatar
    @user = Current.user
    ActiveRecord::Base.transaction do
      @user.avatar_image.purge
      @user.update!(avatar_url: nil)
    end
    redirect_to profile_path, notice: "Avatar removed."
  end

  def destroy
    Current.user.destroy
    terminate_session
    redirect_to new_session_path, status: :see_other, notice: "Profile deleted."
  end

  private
    def profile_json(user)
      { full_name: user.full_name, email: user.email, role: user.role, avatar_url: user.avatar_url,
        avatar_attached: user.avatar_image.attached?,
        avatar_image_url: (url_for(user.avatar_image) if user.avatar_image.attached?) }
    end

    def profile_params
      params.expect(user: [ :full_name, :email, :avatar_image, :avatar_url ])
    end

    # A freshly uploaded file takes precedence over any URL carried in the form.
    def profile_params_without_stale_avatar
      avatar_upload? ? profile_params.merge(avatar_url: nil) : profile_params
    end

    def avatar_upload?
      params.dig(:user, :avatar_image).is_a?(ActionDispatch::Http::UploadedFile)
    end

    def replacing_attachment_with_url?
      !avatar_upload? && profile_params[:avatar_url].present? && @user.avatar_image.attached?
    end
end
