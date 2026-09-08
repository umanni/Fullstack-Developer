require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects an authenticated session" do
    session = users(:admin).sessions.create!
    cookies.signed[:session_id] = session.id

    connect

    assert_equal users(:admin), connection.current_user
  end

  test "rejects a visitor without a session" do
    assert_reject_connection { connect }
  end
end
