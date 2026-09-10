require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "show returns ok when the database is reachable" do
    get rails_health_check_path

    assert_response :success
    assert_equal({ "status" => "ok" }, response.parsed_body)
  end
end
