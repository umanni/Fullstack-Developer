class ProfilesController < ApplicationController
  def show
    @user = Current.user
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Users::Update.call(user: Current.user, attributes: profile_params)

    if @user.errors.empty?
      redirect_to profile_path, notice: "Your profile was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    user = Users::Destroy.call(user: Current.user)

    if user.destroyed?
      terminate_session
      redirect_to root_path, notice: "Your account was deleted.", status: :see_other
    else
      redirect_to profile_path, alert: user.errors.full_messages.to_sentence
    end
  end

  private
    def profile_params
      params.expect(user: %i[ full_name email avatar_image avatar_image_url ])
    end
end
