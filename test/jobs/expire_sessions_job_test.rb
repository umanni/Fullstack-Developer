require "test_helper"

class ExpireSessionsJobTest < ActiveJob::TestCase
  test "destroys only expired sessions and returns the count" do
    user = User.create!(full_name: "Sessions", email: "expire-sessions@example.com", password: "Password123", password_confirmation: "Password123")
    expired = user.sessions.create!(last_active_at: 31.days.ago, user_agent: "test", ip_address: "127.0.0.1")
    active = user.sessions.create!(last_active_at: 1.day.ago, user_agent: "test", ip_address: "127.0.0.1")

    count = ExpireSessionsJob.perform_now

    assert_equal 1, count
    assert_not Session.exists?(expired.id)
    assert Session.exists?(active.id)
  end

  test "is a no-op when nothing is expired" do
    user = User.create!(full_name: "Sessions", email: "expire-none@example.com", password: "Password123", password_confirmation: "Password123")
    active = user.sessions.create!(last_active_at: 1.minute.ago, user_agent: "test", ip_address: "127.0.0.1")

    assert_equal 0, ExpireSessionsJob.perform_now

    assert Session.exists?(active.id)
  end
end
