# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :line
    skip "/test/"
    skip "/config/"
    skip "/vendor/"
    skip "app/channels/"
    skip "app/mailers/"
    skip "app/views/"
    skip "app/javascript/"
    minimum_coverage 90
  end
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "active_job/test_helper"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    if ENV["COVERAGE"]
      parallelize_setup do |worker|
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end

      parallelize_teardown do
        SimpleCov.result
      end
    end

    fixtures :all

    include ActiveJob::TestHelper

    def sign_in_as(user)
      post session_url, params: { email_address: user.email_address, password: "password123" }
    end
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: "password123" }
  end
end
