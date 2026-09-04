# One place decides what the API says about a person, so a new column does not
# quietly become public by virtue of existing.
class UserSerializer
  ATTRIBUTES = %i[id full_name email_address role locale created_at updated_at].freeze

  def initialize(user, avatar_url: nil)
    @user = user
    @avatar_url = avatar_url
  end

  def self.collection(users, **)
    users.map { |user| new(user, **).as_json }
  end

  def as_json(*)
    ATTRIBUTES.index_with { |attribute| @user.public_send(attribute) }
              .merge("avatar_url" => @user.displayable_avatar_url)
              .transform_keys(&:to_s)
  end
end
