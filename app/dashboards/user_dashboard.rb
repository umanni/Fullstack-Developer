require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
  id: Field::Number,
  username: Field::String,
  role: Field::String,
  avatar_image: ActiveStorageField,
  password: Field::String.with_options(searchable: false),
  password_confirmation: Field::String.with_options(searchable: false),
  created_at: Field::DateTime,
  updated_at: Field::DateTime
}.freeze

COLLECTION_ATTRIBUTES = %i[
  id
  username
  role
  avatar_image
].freeze


FORM_ATTRIBUTES = %i[
  username
  role
  password
  password_confirmation
  avatar_image
].freeze


SHOW_PAGE_ATTRIBUTES = %i[
  id
  username
  role
  avatar_image
  created_at
  updated_at
].freeze

  def display_resource(user)
    user.username
  end
end
