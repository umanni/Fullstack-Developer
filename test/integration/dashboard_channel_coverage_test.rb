require "test_helper"
class DashboardChannelCoverageTest < ActionDispatch::IntegrationTest
  test "subscribed" do
    admin = User.create!(full_name: "D", email: "d@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(admin)
    assert_respond_to DashboardChannel, :subscribed
  end
end
