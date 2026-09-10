require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  setup do
    @user = User.create!(full_name: "Cable User", email: "cable-conn@example.com", password: "Password123", password_confirmation: "Password123")
  end

  test "connects with valid session cookie" do
    session = @user.sessions.create!
    cookies.signed[:session_id] = session.id

    connect

    assert_equal @user.id, connection.current_user.id
  end

  test "rejects connection without session cookie" do
    assert_reject_connection { connect }
  end

  test "rejects connection with unknown session id" do
    cookies.signed[:session_id] = 0

    assert_reject_connection { connect }
  end
end
