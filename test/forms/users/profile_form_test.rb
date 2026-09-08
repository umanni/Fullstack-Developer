require "test_helper"

class Users::ProfileFormTest < ActiveSupport::TestCase
  test "updates the own full name and email" do
    user = users(:two)
    form = Users::ProfileForm.new(
      { full_name: "Renamed User", email_address: "renamed@iam.test", avatar_url: user.avatar_url },
      user: user
    )

    assert form.update
    assert_equal "Renamed User", user.reload.full_name
    assert_equal "renamed@iam.test", user.reload.email_address
  end

  test "does not require a password" do
    user = users(:two)
    form = Users::ProfileForm.new(attributes_for(user), user: user)

    assert form.update
    assert_empty form.errors[:password]
  end

  test "updates the password when provided and confirmed" do
    user = users(:two)
    form = Users::ProfileForm.new(
      attributes_for(user).merge(password: "NewPassword123!", password_confirmation: "NewPassword123!"),
      user: user
    )

    assert form.update
    assert user.reload.authenticate("NewPassword123!")
  end

  test "rejects a password without a matching confirmation" do
    user = users(:two)
    form = Users::ProfileForm.new(
      attributes_for(user).merge(password: "NewPassword123!", password_confirmation: "Different123!"),
      user: user
    )

    assert_not form.update
    assert form.errors[:password_confirmation].present?
    assert_not user.authenticate("NewPassword123!")
  end

  test "rejects a short password" do
    user = users(:two)
    form = Users::ProfileForm.new(
      attributes_for(user).merge(password: "short", password_confirmation: "short"),
      user: user
    )

    assert_not form.update
    assert form.errors[:password].present?
  end

  test "rejects a duplicate email address merging the model error" do
    user = users(:two)
    form = Users::ProfileForm.new(
      { full_name: user.full_name, email_address: users(:one).email_address, avatar_url: user.avatar_url },
      user: user
    )

    assert_not form.update
    assert_includes form.errors[:email_address], "has already been taken"
  end

  test "keeps the avatar when the form does not touch it" do
    user = users(:one)
    form = Users::ProfileForm.new(attributes_for(user), user: user)

    assert form.update
    assert_equal "https://example.com/avatars/admin.png", user.reload.avatar_url
  end

  private

  def attributes_for(user)
    {
      full_name: user.full_name,
      email_address: user.email_address,
      avatar_url: user.avatar_url
    }
  end
end
