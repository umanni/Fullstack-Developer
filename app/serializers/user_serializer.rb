class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :full_name, :email, :avatar_url

  attribute :user_role do |user|
    next nil unless user.user_role

    {
      id: user.user_role.id,
      label: user.user_role.label,
      is_admin: user.user_role.is_admin
    }
  end

  attribute :avatar_image_url do |user|
    user.avatar_display_url
  end

  belongs_to :user_role
end
