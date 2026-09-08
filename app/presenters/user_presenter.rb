# frozen_string_literal: true

class UserPresenter
  AVATAR_PLACEHOLDER = "/images/avatar-placeholder.png"

  def initialize(user)
    @user = user
  end

  def to_inertia
    {
      id: id,
      full_name: full_name,
      email_address: email_address,
      role: role,
      avatar_source: avatar_source
    }
  end

  private

  attr_reader :user

  delegate :id, :full_name, :email_address, :role, to: :user

  def avatar_source
    return user.avatar if user.avatar.attached?
    return user.avatar_url if user.avatar_url.present?

    AVATAR_PLACEHOLDER
  end
end
