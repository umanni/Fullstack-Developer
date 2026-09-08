require "test_helper"

class ImportProgressChannelTest < ActionCable::Channel::TestCase
  tests ImportProgressChannel::Channel
  test "subscribes an admin to the import stream" do
    import = UserImport.create!(user: users(:one)) do |record|
      record.file.attach(io: StringIO.new("Full name,Email address\n"), filename: "users.csv", content_type: "text/csv")
    end
    stub_connection current_user: users(:one)

    subscribe import_id: import.id

    assert subscription.confirmed?
    assert_has_stream_for import
  end

  test "rejects unknown imports" do
    stub_connection current_user: users(:one)

    subscribe import_id: 999_999

    assert subscription.rejected?
  end

  test "rejects non-admin subscriptions" do
    import = UserImport.create!(user: users(:one)) do |record|
      record.file.attach(io: StringIO.new("Full name,Email address\n"), filename: "users.csv", content_type: "text/csv")
    end
    stub_connection current_user: users(:two)

    subscribe import_id: import.id

    assert subscription.rejected?
  end
end
