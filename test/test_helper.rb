ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"]
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch
    primary_coverage :line
    minimum_coverage line: 90
    skip %r{^/test/}
    skip %r{^/config/}
    skip %r{^/db/}
  end
end

require_relative "../config/environment"
require "rails/test_help"
require "inertia_rails/minitest"
require "action_cable/test_helper"
require "action_mailer/test_helper"
require_relative "test_helpers/file_test_helper"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    parallel_workers = if ENV["PARALLEL_WORKERS"]
      Integer(ENV.fetch("PARALLEL_WORKERS"))
    elsif ENV["CI"]
      :number_of_processors
    else
      1
    end
    parallel_executor = ENV.fetch("PARALLEL_EXECUTOR", "processes").to_sym
    parallelize(workers: parallel_workers, with: parallel_executor)
    fixtures :all

    include ActiveJob::TestHelper
    include ActionCable::TestHelper
    include ActionMailer::TestHelper
    include FileTestHelper
  end
end
