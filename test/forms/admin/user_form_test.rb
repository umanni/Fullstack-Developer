require "test_helper"

class Admin::UserFormTest < ActiveSupport::TestCase
  test "creates an admin user" do
    form = form_for(role: "admin", full_name: "Bob Admin", email_address: "bob@iam.test")

    assert form.save
    assert form.user.persisted?
    assert_equal "admin", form.user.role
    assert form.user.authenticate("Password123!")
  end

  test "creates a regular user" do
    form = form_for(full_name: "Carol User", email_address: "carol@iam.test")

    assert form.save
    assert_equal "user", form.user.role
  end

  test "create requires a password" do
    form = form_for(full_name: "No Pass", email_address: "nopass@iam.test", password: "", password_confirmation: "")

    assert_not form.save
    assert form.errors[:password].present?
    assert_not form.user.persisted?
  end

  test "create rejects an unknown role" do
    form = form_for(full_name: "Rogue", email_address: "rogue@iam.test", role: "superadmin")

    assert_not form.save
    assert form.errors[:role].present?
  end

  test "update does not require a password and can change the role" do
    user = users(:two)
    form = Admin::UserForm.new(
      {
        full_name: "Ursula Updated",
        email_address: user.email_address,
        role: "admin",
        avatar_url: user.avatar_url
      },
      user: user
    )

    assert form.update
    assert_equal "Ursula Updated", user.reload.full_name
    assert_equal "admin", user.role
  end

  test "update accepts an optional new password" do
    user = users(:two)
    form = Admin::UserForm.new(
      attributes_for(user).merge(password: "NewPassword123!", password_confirmation: "NewPassword123!"),
      user: user
    )

    assert form.update
    assert user.reload.authenticate("NewPassword123!")
  end

  test "update keeps the avatar when the form does not touch it" do
    user = users(:one)
    form = Admin::UserForm.new(attributes_for(user), user: user)

    assert form.update
    assert_equal "https://example.com/avatars/admin.png", user.reload.avatar_url
  end

  test "update rejects a mismatched password confirmation" do
    user = users(:two)
    form = Admin::UserForm.new(
      attributes_for(user).merge(password: "NewPassword123!", password_confirmation: "Different123!"),
      user: user
    )

    assert_not form.update
    assert form.errors[:password_confirmation].present?
    assert_not user.authenticate("NewPassword123!")
  end

  private

  def form_for(**overrides)
    Admin::UserForm.new(valid_registration_attributes.merge(overrides))
  end

  def valid_registration_attributes
    {
      full_name: "Valid Admin",
      email_address: "valid-admin@iam.test",
      role: "user",
      password: "Password123!",
      password_confirmation: "Password123!",
      avatar_url: "https://example.com/avatars/valid-admin.png"
    }
  end

  def attributes_for(user)
    {
      full_name: user.full_name,
      email_address: user.email_address,
      role: user.role,
      avatar_url: user.avatar_url
    }
  end
end
