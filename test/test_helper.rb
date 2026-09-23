if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "/test/"
    add_filter "/config/"
    add_filter "/vendor/"
    minimum_coverage 90
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    def sign_in_as(user)
      post session_url, params: { email: user.email, password: "password123" }
    end
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in_as(user)
      post session_url, params: { email: user.email, password: "password123" }
    end
  end
end
