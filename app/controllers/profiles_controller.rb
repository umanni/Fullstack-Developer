class ProfilesController < ApplicationController
  before_action :set_user

  def show; end

  def edit; end

  def update
    @user.avatar.purge if params.dig(:user, :remove_avatar) == "1"

    if @user.update(profile_params)
      redirect_to profile_path, notice: t("profiles.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    user = @user
    terminate_session
    user.destroy!

    redirect_to new_session_path, status: :see_other, notice: t("profiles.deleted")
  end

  private

  # Always the signed-in user. Nothing here reads an id from the request, so
  # there is no identifier to tamper with.
  def set_user
    @user = Current.user
  end

  # `role` is not permitted: a user cannot promote themselves. `remove_avatar`
  # is read directly in the action rather than assigned, since it is an
  # instruction rather than an attribute.
  def profile_params
    params.expect(user: %i[full_name email_address avatar_url avatar])
  end
end
