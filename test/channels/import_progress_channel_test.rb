require "test_helper"

class ImportProgressChannelTest < ActionCable::Channel::TestCase
  test "administrator subscribes to an existing import" do
    user_import = create_user_import
    stub_connection current_user: users(:admin)

    subscribe id: user_import.id

    assert_predicate subscription, :confirmed?
    assert_has_stream_for user_import
  end

  test "rejects missing imports" do
    stub_connection current_user: users(:admin)

    subscribe id: -1

    assert_predicate subscription, :rejected?
  end

  test "rejects standard users" do
    stub_connection current_user: users(:member)

    subscribe id: create_user_import.id

    assert_predicate subscription, :rejected?
  end
end
