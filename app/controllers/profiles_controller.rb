# app/controllers/profiles_controller.rb

class ProfilesController < ApplicationController
  before_action :set_profile

  def show
    authorize! @profile
    render inertia: "Profile/Show", props: { user: UserSerializer.new(@profile).as_json }
  end

  def edit
    authorize! @profile
    render inertia: "Profile/Edit", props: { user: UserSerializer.new(@profile).as_json }
  end

  def update
    authorize! @profile

    if @profile.update(permitted_params(@profile, :user))
      redirect_to profile_path, notice: "Profile updated."
    else
      redirect_to edit_profile_path, inertia: { errors: @profile.errors }
    end
  end

  def destroy
    authorize! @profile
    @profile.destroy!
    terminate_session
    redirect_to root_path, notice: "Your account has been deleted."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to profile_path, alert: @profile.errors.full_messages.to_sentence
  end

  private

  def set_profile = @profile = Current.user
end
