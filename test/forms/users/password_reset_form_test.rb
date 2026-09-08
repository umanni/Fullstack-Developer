require "test_helper"

class PasswordResetFormTest < ActiveSupport::TestCase
  test "resets only the password without touching identity" do
    user = users(:two)
    form = form_for(user, password: "NewPass123!", password_confirmation: "NewPass123!")

    assert form.update
    assert user.reload.authenticate("NewPass123!")
    assert_equal "Ursula User", user.full_name
    assert_equal "user@iam.test", user.email_address
    assert_empty form.errors
  end

  test "rejects a blank password" do
    user = users(:two)
    form = form_for(user, password: "", password_confirmation: "")

    assert_not form.update
    assert_includes form.errors[:password], "can't be blank"
  end

  test "rejects a mismatched confirmation" do
    user = users(:two)
    form = form_for(user, password: "NewPass123!", password_confirmation: "Different123!")

    assert_not form.update
    assert_includes form.errors[:password_confirmation], "doesn't match Password confirmation"
  end

  test "does not require an avatar (imported users without one can reset)" do
    user = User.create!(
      full_name: "Sem Avatar",
      email_address: "sem.avatar@iam.test",
      password: "OldPass123!",
      password_confirmation: "OldPass123!"
    )
    form = form_for(user, password: "NewPass123!", password_confirmation: "NewPass123!")

    assert form.update
    assert user.reload.authenticate("NewPass123!")
  end

  private

  def form_for(user, **overrides)
    Users::PasswordResetForm.new(overrides, user: user)
  end
end
