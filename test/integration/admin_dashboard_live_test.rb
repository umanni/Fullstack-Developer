require "test_helper"

class AdminDashboardLiveTest < ActionDispatch::IntegrationTest
  include ActionCable::TestHelper

  setup do
    @admin = User.create!(full_name: "Admin", email: "live-admin@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
    sign_in_as(@admin)
  end

  test "dashboard renders live component with counts" do
    get admin_root_path
    assert_response :success
    assert_match "Admin/Dashboard/Show", response.body
    assert_match "total_users", response.body
  end

  test "creating user broadcasts dashboard update over cable" do
    assert_broadcasts("dashboard", 1) do
      User.create!(full_name: "Live", email: "live@example.com", password: "Password123", password_confirmation: "Password123")
    end
  end
end
