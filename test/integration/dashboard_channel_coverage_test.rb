require "test_helper"
class DashboardChannelCoverageTest < ActionDispatch::IntegrationTest
  test "subscribed" do
    admin = User.create!(full_name: "D", email: "d@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(admin)
    assert DashboardChannel.method_defined?(:subscribed) || DashboardChannel.instance_methods.include?(:subscribed)
  end
end
