require "test_helper"

class AuthenticationConcernTest < ActiveSupport::TestCase
  class DummyController < ActionController::Base
    include Authentication

    def root_url
      "http://test.host/"
    end
  end

  test "falls back to root_url without return location" do
    controller = DummyController.new
    controller.define_singleton_method(:session) { {} }

    assert_equal "http://test.host/", controller.send(:after_authentication_url)
  end

  test "returns stored return location when present" do
    controller = DummyController.new
    controller.define_singleton_method(:session) do
      { return_to_after_authenticating: "http://test.host/profile" }
    end

    assert_equal "http://test.host/profile", controller.send(:after_authentication_url)
  end

  test "inertia controller inherits application controller" do
    assert_equal ApplicationController, InertiaController.superclass
  end
end
