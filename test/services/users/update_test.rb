require "test_helper"

class Users::UpdateTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "updates profile fields without changing the role" do
    user = users(:member)

    Users::Update.call(user:, attributes: { full_name: "Updated Member", email: "updated@example.com" })

    assert_equal "Updated Member", user.reload.full_name
    assert_predicate user, :user?
  end

  test "an uploaded avatar replaces a remote URL" do
    user = users(:member)
    upload = Rack::Test::UploadedFile.new(Rails.root.join("public/icon.png"), "image/png")

    Users::Update.call(user:, attributes: { avatar_image: upload })

    assert_predicate user.reload.avatar_image, :attached?
    assert_nil user.avatar_image_url
  end

  test "a remote URL replaces an uploaded avatar after a valid save" do
    user = users(:member)
    user.avatar_image.attach(io: File.open(Rails.root.join("public/icon.png")), filename: "avatar.png", content_type: "image/png")

    assert_enqueued_with(job: ActiveStorage::PurgeJob) do
      Users::Update.call(user:, attributes: { avatar_image_url: "https://example.com/new.png" })
    end

    assert_equal "https://example.com/new.png", user.reload.avatar_image_url
  end

  test "preserves the existing upload when the replacement URL is invalid" do
    user = users(:member)
    user.avatar_image.attach(io: File.open(Rails.root.join("public/icon.png")), filename: "avatar.png", content_type: "image/png")

    assert_no_enqueued_jobs do
      Users::Update.call(user:, attributes: { avatar_image_url: "http://insecure.example/avatar.png" })
    end

    assert_predicate user.reload.avatar_image, :attached?
  end
end
