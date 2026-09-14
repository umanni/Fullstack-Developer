require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "identifies the person behind a signed session cookie" do
    cookies.signed[:session_id] = users(:admin).sessions.create!.id

    connect

    assert_equal users(:admin), connection.current_user
  end

  test "refuses a visitor carrying no session" do
    assert_reject_connection { connect }
  end

  # The dashboard stream is admin data. An unsigned cookie is a guess at a row id.
  test "refuses a session cookie this application did not sign" do
    cookies[:session_id] = users(:admin).sessions.create!.id

    assert_reject_connection { connect }
  end
end
