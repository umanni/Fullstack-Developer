require "test_helper"

class UserPresenterTest < ActiveSupport::TestCase
  test "#to_inertia presents the user contract for the frontend" do
    presenter = UserPresenter.new(users(:one))

    payload = presenter.to_inertia

    assert_equal users(:one).id, payload[:id]
    assert_equal "Ivy Admin", payload[:full_name]
    assert_equal "admin@iam.test", payload[:email_address]
    assert_equal "admin", payload[:role]
  end

  test "#to_inertia resolves the remote avatar url" do
    payload = UserPresenter.new(users(:one)).to_inertia

    assert_equal "https://example.com/avatars/admin.png", payload[:avatar_source]
  end

  test "#to_inertia falls back to a placeholder when no avatar is present" do
    user = User.new(
      email_address: "new@iam.test",
      password: "Password123!",
      full_name: "New User",
      role: :user
    )

    payload = UserPresenter.new(user).to_inertia

    assert_equal UserPresenter::AVATAR_PLACEHOLDER, payload[:avatar_source]
  end
end
