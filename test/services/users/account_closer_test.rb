require "test_helper"

class Users::AccountCloserTest < ActiveSupport::TestCase
  test "destroys the account" do
    user = users(:two)

    assert_difference "User.count", -1 do
      Users::AccountCloser.call(user)
    end
    assert_not User.exists?(user.id)
  end

  test "keeps the user import history by nullifying the reference" do
    user = users(:two)
    import = user.user_imports.create!(status: :completed) do |record|
      record.file.attach(io: StringIO.new("x\n"), filename: "users.csv", content_type: "text/csv")
    end

    Users::AccountCloser.call(user)

    import.reload
    assert import.persisted?
    assert_nil import.user_id
  end

  test "destroys the user sessions via dependent destroy" do
    user = users(:two)
    user.sessions.create!(ip_address: "10.0.0.1", user_agent: "test")

    assert_difference "Session.count", -1 do
      Users::AccountCloser.call(user)
    end
  end
end
