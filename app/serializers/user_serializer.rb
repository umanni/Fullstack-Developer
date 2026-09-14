class UserSerializer
  include Rails.application.routes.url_helpers

  VARIANT = { resize_to_fill: [ 160, 160 ], format: :webp }.freeze

  def self.collection(users) = users.map { new(_1).as_json }

  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: user.id,
      full_name: user.full_name,
      email_address: user.email_address,
      role: user.role,
      admin: user.admin?,
      avatar_url: avatar_url,
      remote_avatar_url: user.avatar_url.presence,
      created_at: user.created_at.iso8601
    }
  end

  private

  attr_reader :user

  def avatar_url
    return user.avatar_url.presence unless user.avatar_image.attached?

    rails_representation_url(user.avatar_image.variant(**VARIANT), only_path: true)
  end
end
