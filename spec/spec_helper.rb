# Coverage has to start before any application code is loaded, which is why it
# lives at the very top of this file rather than in rails_helper.
require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch

  # Each parallel worker writes its own result and SimpleCov merges them, so
  # the 90% gate is measured against the whole suite rather than one shard.
  command_name "rspec#{ENV.fetch("TEST_ENV_NUMBER", nil)}"
  use_merging true
  merge_timeout 600

  minimum_coverage line: 90, branch: 80

  # Excluded because they contain no branching logic of our own: generated
  # schemas, framework configuration and the mailer/job base classes Rails
  # writes for us.
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "app/channels/application_cable/"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Jobs", "app/jobs"
  add_group "Views", "app/views"
  add_group "Helpers", "app/helpers"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.warnings = false

  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end
