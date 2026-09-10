require "test_helper"

class UserImportChannelTest < ActionCable::Channel::TestCase
  setup do
    @admin = User.create!(full_name: "Import Admin", email: "imp-chan-admin@example.com", password: "Password123", password_confirmation: "Password123", role: :admin)
    @user = User.create!(full_name: "Import User", email: "imp-chan-user@example.com", password: "Password123", password_confirmation: "Password123")
    @import = UserImport.new(status: :pending, total_rows: 0, processed_rows: 0, failed_rows: 0)
    @import.file.attach(io: StringIO.new("full_name,email,password\nA,a@x.co,Password123\n"), filename: "users.csv", content_type: "text/csv")
    @import.save!
  end

  test "subscribes for admin" do
    stub_connection current_user: @admin
    subscribe(id: @import.id)

    assert subscription.confirmed?
    assert_has_stream_for @import
  end

  test "rejects subscription for non-admin" do
    stub_connection current_user: @user
    subscribe(id: @import.id)

    assert subscription.rejected?
  end
end
