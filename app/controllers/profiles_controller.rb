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
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render inertia: "Profile/Edit", props: { user: profile_json(@user) }, status: :unprocessable_entity
    end
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
end
