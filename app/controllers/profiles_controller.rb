class ProfilesController < InertiaController
  def show
    render inertia: "Profile/Show", props: { profile: UserPresenter.new(Current.user).as_json }
  end

  def edit
    render inertia: "Profile/Edit", props: { profile: UserPresenter.new(Current.user).as_json }
  end

  def update
    attributes = profile_params
    remove_blank_password!(attributes)
    remove_avatar = ActiveModel::Type::Boolean.new.cast(attributes.delete(:remove_avatar))

    if Current.user.update(attributes)
      Current.user.avatar_image.purge if remove_avatar
      redirect_to profile_path, notice: "Your profile has been updated."
    else
      redirect_to edit_profile_path, inertia: { errors: Current.user.errors }
    end
  end

  def destroy
    Users::Destroyer.call(user: Current.user, actor: Current.user, allow_self: true)
    terminate_session
    redirect_to new_registration_path,
      status: :see_other,
      notice: "Your account has been deleted.",
      inertia: { clear_history: true }
  rescue Users::Destroyer::Error => error
    redirect_to profile_path, alert: error.message
  end

  private
    def profile_params
      params.expect(user: %i[full_name email password password_confirmation avatar_image remove_avatar])
    end
end
