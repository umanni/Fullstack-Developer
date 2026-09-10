require "test_helper"

class OnlyAdminGuardTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Solo Admin", email: "solo-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
    sign_in_as(@admin)
  end

  test "cannot delete the only admin" do
    assert_no_difference("User.count") do
      delete admin_user_path(@admin)
    end
    assert_redirected_to admin_users_path
    follow_redirect!
    assert_match "Cannot delete the only admin", response.body
  end

  test "can delete an admin when another admin exists" do
    other = User.create!(full_name: "Other Admin", email: "other-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)

    assert_difference("User.count", -1) do
      delete admin_user_path(@admin)
    end
    assert_redirected_to admin_users_path
    assert_not User.exists?(@admin.id)
    assert User.exists?(other.id)
  end
end
