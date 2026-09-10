require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "show returns ok when the database is reachable" do
    get rails_health_check_path

    assert_response :success
    assert_equal({ "status" => "ok" }, response.parsed_body)
  end

  test "show reports unavailable when the database is down" do
    connection = ActiveRecord::Base.connection
    connection.define_singleton_method(:execute) { |*| raise ActiveRecord::ConnectionNotEstablished }

    begin
      get rails_health_check_path
    ensure
      connection.singleton_class.send(:remove_method, :execute)
    end

    assert_response :service_unavailable
    assert_equal({ "status" => "unavailable" }, response.parsed_body)
  end
end
