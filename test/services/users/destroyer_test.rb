require "test_helper"

class Users::DestroyerTest < ActiveSupport::TestCase
  test "deletes a different user" do
    assert_difference "User.count", -1 do
      Users::Destroyer.call(user: users(:member), actor: users(:admin))
    end
  end

  test "rejects self deletion from the admin workflow" do
    error = assert_raises(Users::Destroyer::Error) do
      Users::Destroyer.call(user: users(:admin), actor: users(:admin))
    end

    assert_match(/profile page/, error.message)
  end

  test "allows self deletion from the profile workflow" do
    assert_difference "User.count", -1 do
      Users::Destroyer.call(user: users(:member), actor: users(:member), allow_self: true)
    end
  end

  test "preserves the last administrator" do
    users(:another_admin).update!(role: :user)

    error = assert_raises(Users::Destroyer::Error) do
      Users::Destroyer.call(user: users(:admin), actor: users(:admin), allow_self: true)
    end

    assert_match(/last administrator/, error.message)
    assert User.exists?(users(:admin).id)
  end
end
