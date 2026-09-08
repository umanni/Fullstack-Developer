require "test_helper"

class ApplicationCableConnectionTest < ActionCable::Connection::TestCase
  tests ApplicationCable::Connection

  test "connects when the signed session cookie is present" do
    user = users(:one)
    app_session = user.sessions.create!(user_agent: "cable", ip_address: "127.0.0.1")
    cookies.signed[:session_id] = app_session.id

    connect

    assert_equal user, connection.current_user
  end

  test "rejects connections without a session cookie" do
    assert_reject_connection { connect }
  end

  test "rejects connections with an unknown session id" do
    cookies.signed[:session_id] = 999_999

    assert_reject_connection { connect }
  end
end
