# frozen_string_literal: true

class ProfilesController < ApplicationController
  # Authenticated by the Authentication concern. Identity always comes from
  # Current.user — the singular route never carries an id (anti-IDOR by design).

  def show
    render inertia: "Profile/Show", props: {
      user: UserPresenter.new(Current.user).to_inertia,
      urls: {
        profile_url: profile_path,
        admin_url: admin_root_path,
        edit_url: edit_profile_path,
        delete_url: profile_path
      }
    }
  end

  def edit
    render inertia: "Profile/Edit", props: {
      urls: { profile_url: profile_path, admin_url: admin_root_path, submit_url: profile_path, cancel_url: profile_path },
      form: profile_attributes
    }
  end

  def update
    form = Users::ProfileForm.new(profile_params, user: Current.user)

    if form.update
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render inertia: "Profile/Edit", props: {
        urls: { profile_url: profile_path, admin_url: admin_root_path, submit_url: profile_path, cancel_url: profile_path },
        form: echoed_attributes,
        errors: form.errors.to_hash
      }
    end
  end

  def destroy
    Users::AccountCloser.call(Current.user)
    terminate_session
    redirect_to new_session_path, notice: "Your account has been closed. Goodbye!"
  end

  private

  def profile_params
    params.permit(:full_name, :email_address, :avatar, :avatar_url, :password, :password_confirmation)
  end

  def profile_attributes
    {
      full_name: Current.user.full_name,
      email_address: Current.user.email_address,
      avatar_url: Current.user.avatar_url
    }
  end

  def echoed_attributes
    params.permit(:full_name, :email_address, :avatar_url).to_h
  end
end
