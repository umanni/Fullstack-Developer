require "test_helper"

class AvatarUploadTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(full_name: "Pic", email: "picup@example.com", password: "Password123", password_confirmation: "Password123")
    @admin = User.create!(full_name: "Admin", email: "picadmin@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
  end

  test "profile avatar file upload attaches" do
    sign_in_as(@user)
    file = Rack::Test::UploadedFile.new(StringIO.new("img"), "image/png", original_filename: "a.png")
    patch profile_path, params: { user: { avatar_image: file } }
    assert_redirected_to profile_path
    assert @user.reload.avatar_image.attached?
    get profile_path
    assert_match "avatar_image_url", response.body
    assert_match "/rails/active_storage/", response.body
  end

  test "admin creates user with avatar file" do
    sign_in_as(@admin)
    file = Rack::Test::UploadedFile.new(StringIO.new("img"), "image/png", original_filename: "b.png")
    assert_difference("User.count", 1) do
      post admin_users_path, params: { user: { full_name: "Av", email: "av@example.com", password: "Password123", password_confirmation: "Password123", avatar_image: file } }
    end
    assert User.find_by(email: "av@example.com").avatar_image.attached?
  end
end
