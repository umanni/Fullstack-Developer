require "test_helper"

class AvatarManagementTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(full_name: "Avatar User", email: "avatar-mgmt@example.com", password: "password123", password_confirmation: "password123")
    @admin = User.create!(full_name: "Avatar Admin", email: "avatar-mgmt-admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
  end

  test "user removes own avatar" do
    @user.avatar_image.attach(io: StringIO.new("img"), filename: "a.png", content_type: "image/png")
    @user.update!(avatar_url: "https://example.com/a.png")
    sign_in_as(@user)

    delete remove_avatar_profile_path
    assert_redirected_to profile_path

    assert_not @user.reload.avatar_image.attached?
    assert_nil @user.reload.avatar_url
  end

  test "uploading file clears existing url" do
    @user.update!(avatar_url: "https://example.com/old.png")
    sign_in_as(@user)

    file = Rack::Test::UploadedFile.new(StringIO.new("img"), "image/png", original_filename: "new.png")
    patch profile_path, params: { user: { avatar_image: file } }
    assert_redirected_to profile_path

    assert_nil @user.reload.avatar_url
  end

  test "setting url purges existing attachment" do
    @user.avatar_image.attach(io: StringIO.new("img"), filename: "old.png", content_type: "image/png")
    sign_in_as(@user)

    patch profile_path, params: { user: { avatar_url: "https://example.com/new.png" } }
    assert_redirected_to profile_path

    assert_not @user.reload.avatar_image.attached?
    assert_equal "https://example.com/new.png", @user.reload.avatar_url
  end

  test "admin removes user avatar" do
    @user.avatar_image.attach(io: StringIO.new("img"), filename: "a.png", content_type: "image/png")
    @user.update!(avatar_url: "https://example.com/a.png")
    sign_in_as(@admin)

    delete remove_avatar_admin_user_path(@user)
    assert_redirected_to admin_users_path

    assert_not @user.reload.avatar_image.attached?
    assert_nil @user.reload.avatar_url
  end
end
