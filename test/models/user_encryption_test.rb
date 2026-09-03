require "test_helper"

class UserEncryptionTest < ActiveSupport::TestCase
  test "fixture users authenticate with known password" do
    assert User.authenticate_by(email_address: users(:admin).email_address, password: "password123")
    assert User.authenticate_by(email_address: users(:member).email_address, password: "password123")
  end

  test "email ciphertext differs from plaintext attribute" do
    user = users(:member)
    raw = User.connection.select_value(
      User.sanitize_sql_array([ "SELECT email_address FROM users WHERE id = ?", user.id ])
    )

    assert_not_equal user.email_address, raw
  end

  test "deterministic encryption supports find_by email" do
    assert_equal users(:admin).id, User.find_by(email_address: users(:admin).email_address).id
  end
end
