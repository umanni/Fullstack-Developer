require "test_helper"

class UserTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup { clear_enqueued_jobs }

  test "normalizes names and email addresses" do
    user = build_user(full_name: "  Dorothy   Vaughan ", email: " DOROTHY@EXAMPLE.COM ")

    assert_predicate user, :valid?
    assert_equal "Dorothy Vaughan", user.full_name
    assert_equal "dorothy@example.com", user.email
  end

  test "requires structurally valid and unique attributes" do
    user = build_user(full_name: "x", email: users(:member).email.upcase, password: "short")

    assert_not user.valid?
    assert_includes user.errors[:full_name], "is too short (minimum is 2 characters)"
    assert_includes user.errors[:email], "has already been taken"
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "rejects invalid email and role values" do
    user = build_user(email: "not-an-email", role: "owner")

    assert_not user.valid?
    assert_predicate user.errors[:email], :present?
    assert_predicate user.errors[:role], :present?
  end

  test "authenticates a valid password securely" do
    assert users(:member).authenticate("StrongPassword!123")
    assert_not users(:member).authenticate("incorrect-password")
  end

  test "search is case insensitive and treats wildcards literally" do
    exact = build_user(full_name: "Percent % Person", email: "percent@example.com")
    exact.save!
    build_user(full_name: "Someone Else", email: "different@example.com").save!

    assert_equal [ exact ], User.search("% Person").to_a
    assert_includes User.search("PERCENT@EXAMPLE").to_a, exact
  end

  test "accepts supported avatar images" do
    user = build_user
    user.avatar_image.attach(io: StringIO.new("image"), filename: "avatar.webp", content_type: "image/webp")

    assert_predicate user, :valid?
  end

  test "rejects unsupported avatar types" do
    user = build_user
    user.avatar_image.attach(io: StringIO.new("script"), filename: "avatar.svg", content_type: "image/svg+xml")

    assert_not user.valid?
    assert_includes user.errors[:avatar_image], "must be a JPEG, PNG, or WebP image"
  end

  test "broadcasts statistics only for membership-affecting changes" do
    assert_enqueued_with(job: UserStatisticsBroadcastJob) { build_user.save! }

    assert_no_enqueued_jobs(only: UserStatisticsBroadcastJob) do
      users(:member).update!(full_name: "Updated Name")
    end

    assert_enqueued_with(job: UserStatisticsBroadcastJob) do
      users(:member).update!(role: :admin)
    end
  end

  test "deleting a user removes active sessions" do
    user = users(:member)
    user.sessions.create!

    assert_difference "Session.count", -1 do
      user.destroy!
    end
  end

  private
    def build_user(**attributes)
      defaults = {
        full_name: "Dorothy Vaughan",
        email: "dorothy-#{SecureRandom.hex(4)}@example.com",
        role: :user,
        password: "StrongPassword!123",
        password_confirmation: "StrongPassword!123"
      }
      User.new(defaults.merge(attributes))
  end
end
