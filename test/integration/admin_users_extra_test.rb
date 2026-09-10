require "test_helper"

class AdminUsersExtraTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(full_name: "Extra Admin", email: "extra-admin@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
    @user = User.create!(full_name: "Extra User", email: "extra-user@example.com", password: "Password123", password_confirmation: "Password123")
    sign_in_as(@admin)
  end

  test "shows user profile" do
    get admin_user_path(@user)
    assert_response :success
    assert_match "Admin/Users/Show", response.body
  end

  test "renders new user form" do
    get new_admin_user_path
    assert_response :success
    assert_match "Admin/Users/New", response.body
  end

  test "renders edit user form" do
    get edit_admin_user_path(@user)
    assert_response :success
    assert_match "Admin/Users/Edit", response.body
  end

  test "update with invalid params rerenders edit" do
    patch admin_user_path(@user), params: { user: { full_name: "", email: "bad" } }
    assert_response :unprocessable_entity
    assert_match "Admin/Users/Edit", response.body
  end

  test "replaces url when uploading file" do
    @user.update!(avatar_url: "https://example.com/old.png")
    file = Rack::Test::UploadedFile.new(StringIO.new("img"), "image/png", original_filename: "new.png")

    patch admin_user_path(@user), params: { user: { avatar_image: file } }
    assert_redirected_to admin_users_path
    assert_nil @user.reload.avatar_url
  end

  test "purges attachment when setting url" do
    @user.avatar_image.attach(io: StringIO.new("img"), filename: "old.png", content_type: "image/png")

    patch admin_user_path(@user), params: { user: { avatar_url: "https://example.com/new.png" } }
    assert_redirected_to admin_users_path
    assert_not @user.reload.avatar_image.attached?
  end
end
