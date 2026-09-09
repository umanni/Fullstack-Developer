require "test_helper"

class AdminDashboardLiveTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  setup do
    @admin = User.create!(full_name: "Admin", email: "live-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(@admin)
  end

  test "dashboard subscribes to live stream" do
    get admin_root_path
    assert_response :success
    assert_match "turbo-cable-stream-source", response.body
    assert_match "dashboard-counts", response.body
  end

  test "creating user broadcasts dashboard update" do
    assert_broadcasts("admin-dashboard", 1) do
      User.create!(full_name: "Live", email: "live@example.com", password: "password123", password_confirmation: "password123")
    end
  end
end
