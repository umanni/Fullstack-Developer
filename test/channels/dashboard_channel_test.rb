require "test_helper"

class DashboardChannelTest < ActionCable::Channel::TestCase
  setup do
    @admin = User.create!(full_name: "Dash Admin", email: "dash-chan@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    @user = User.create!(full_name: "Dash User", email: "dash-user@example.com", password: "password123", password_confirmation: "password123")
  end

  test "subscribes for admin" do
    stub_connection current_user: @admin
    subscribe

    assert subscription.confirmed?
    assert_has_stream "dashboard"
  end

  test "rejects subscription for non-admin" do
    stub_connection current_user: @user
    subscribe

    assert subscription.rejected?
  end

  test "rejects subscription without user" do
    stub_connection current_user: nil
    subscribe

    assert subscription.rejected?
  end
end
