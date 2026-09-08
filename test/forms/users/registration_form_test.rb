require "test_helper"

class RegistrationFormTest < ActiveSupport::TestCase
  test "persists a user with the :user role regardless of caller input" do
    form = form_for(
      full_name: "New Registrar",
      email_address: "REGISTRAR@iam.test "
    )

    assert form.save
    user = form.user
    assert_predicate user, :user?
    assert_equal "registrar@iam.test", user.email_address
    assert_empty form.errors[:base]
  end

  test "inherits the avatar source rule from the base form (DRY)" do
    form = form_for(full_name: "No Avatar")
    form.avatar_url = nil

    assert_no_difference "User.count" do
      assert_not form.save
    end
    assert_equal [ "Provide an avatar by upload or a remote URL" ], form.errors[:base]
  end

  test "requires a password and a matching confirmation" do
    form = form_for(full_name: "Weak Pass", password: "", password_confirmation: "")

    assert_no_difference "User.count" do
      assert_not form.save
    end
    assert_includes form.errors[:password], "can't be blank"

    form = form_for(full_name: "Mismatch", password: "Password123!", password_confirmation: "Different123!")

    assert_not form.save
    assert_includes form.errors[:password_confirmation], "doesn't match Password confirmation"
  end

  test "rejects a duplicate email address merging the model error" do
    form = form_for(full_name: "Duplicate", email_address: users(:one).email_address)

    assert_no_difference "User.count" do
      assert_not form.save
    end
    assert_includes form.errors[:email_address], "has already been taken"
  end

  test "import rows can skip duplicate emails without failing" do
    existing = users(:two)
    form = form_for(
      full_name: existing.full_name,
      email_address: existing.email_address,
      ignore_duplicate_emails: true,
      require_avatar: false
    )

    assert form.save
    assert_empty form.errors
    assert_equal existing.id, form.user.id
    assert_equal 1, User.where(email_address: existing.email_address).count
  end

  test "duplicates still fail without the import option (default behavior)" do
    existing = users(:two)
    form = form_for(
      full_name: "Intrusa",
      email_address: existing.email_address,
      require_avatar: false
    )

    assert_not form.save
    assert_includes form.errors[:email_address], "has already been taken"
  end

  test "import rows do not require an avatar" do
    form = form_for(
      full_name: "Sem Avatar",
      email_address: "sem.avatar@iam.test",
      require_avatar: false
    )

    assert form.save
    assert_empty form.errors[:base]
  end

  test "rejects a non-http avatar URL" do
    form = form_for(avatar_url: "javascript:alert(1)")

    assert_no_difference "User.count" do
      assert_not form.save
    end
    assert_includes form.errors[:avatar_url], "must be a valid http(s) URL"
  end

  private

  def form_for(**overrides)
    Users::RegistrationForm.new(valid_registration_attributes.merge(overrides))
  end

  def valid_registration_attributes
    {
      full_name: "Valid User",
      email_address: "valid@iam.test",
      password: "Password123!",
      password_confirmation: "Password123!",
      avatar_url: "https://example.com/avatars/valid.png"
    }
  end
end
