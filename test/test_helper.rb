ENV["RAILS_ENV"] ||= "test"

require "simplecov"

# Started before the application is loaded, otherwise everything that runs at boot
# is reported as uncovered.
SimpleCov.start "rails" do
  enable_coverage :branch

  skip %r{\A/test/}
  skip "config/"

  # Without merging, the report shows one worker's share.
  merging true
  merge_timeout 600

  # The brief asks for 90% line. Branch is reported, not enforced.
  minimum_coverage line: 90 if ENV["CI"] || ENV["COVERAGE"]
end

require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do
      SimpleCov.result
    end

    fixtures :all

    setup { ActionController::Base.cache_store.clear }

    include ActiveJob::TestHelper
  end
end
