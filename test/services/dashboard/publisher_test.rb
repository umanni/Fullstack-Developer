require "test_helper"

class Dashboard::PublisherTest < ActiveSupport::TestCase
  test "broadcasts the shared overview payload to the dashboard_stats stream" do
    User.create!(full_name: "Carla", email_address: "carla@publisher.test", password: "Password123!", role: "admin")

    assert_broadcasts "dashboard_stats", 1 do
      Dashboard::Publisher.call
    end
  end

  test "reuses TotalsQuery and Overview#to_inertia (same payload as the render)" do
    payload = capture_broadcasts("dashboard_stats") { Dashboard::Publisher.call }

    assert_equal Dashboard::TotalsQuery.call(User.all).to_inertia, payload.first.symbolize_keys
  end
end
