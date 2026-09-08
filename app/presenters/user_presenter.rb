class UserPresenter
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: user.id,
      full_name: user.full_name,
      email: user.email,
      role: user.role,
      avatar_url: avatar_url,
      created_at: user.created_at.iso8601
    }
  end

  private
    attr_reader :user

    def avatar_url
      return unless user.avatar_image.attached?

      Rails.application.routes.url_helpers.rails_blob_path(user.avatar_image, only_path: true)
    end
end
