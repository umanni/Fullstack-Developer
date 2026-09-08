ENV["RAILS_ENV"] ||= "test"

# Coverage merges need a single process (concurrent workers race the
# .resultset.json file). Default to one worker so the 80% gate is reliable;
# opt into speed with PARALLEL_WORKERS=2..N (the gate is then skipped).
ENV["PARALLEL_WORKERS"] ||= "1"

require "simplecov"
SimpleCov.start do
  track_files "app/**/*.rb"
  add_filter "/test/"
  add_filter "/vendor/"

  group "Controllers", "app/controllers"
  group "Channels", "app/channels"
  group "Forms", "app/forms"
  group "Helpers", "app/helpers"
  group "Jobs", "app/jobs"
  group "Mailers", "app/mailers"
  group "Models", "app/models"
  group "Parsers", "app/parsers"
  group "Policies", "app/policies"
  group "Presenters", "app/presenters"
  group "Queries", "app/queries"
  group "Services", "app/services"
  group "Value Objects", "app/value_objects"
end
SimpleCov.minimum_coverage 80 if ENV["PARALLEL_WORKERS"].to_i == 1
require_relative "../config/environment"
require "rails/test_help"
require "inertia_rails/minitest"
require "action_cable/test_helper"

module SignInHelper
  def log_in_as(user, password: "Password123!")
    post session_path, params: {
      email_address: user.email_address,
      password:
    }
    follow_redirect! if response.redirect?
  end
end

module ActiveSupport
  class TestCase
    include ActionCable::TestHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper

  # Rate limiter counters share Rails.cache across requests; reset them so a
  # test never trips a limit raised by an earlier test in the same process.
  teardown { Rails.cache.clear }
end
