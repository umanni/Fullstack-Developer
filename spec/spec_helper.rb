# Coverage has to start before any application code is loaded, which is why it
# lives at the very top of this file rather than in rails_helper.
#
# The live-updates pass (bin/test --live) runs a handful of system specs and
# would report the rest of the application as uncovered, so it is measured by
# the full run instead.
LIVE_CABLE_PASS = !ENV["CABLE_ADAPTER"].to_s.empty?

# `rswag:specs:swaggerize` re-runs the request specs with --dry-run to read
# their documentation without executing them. Nothing runs, so nothing is
# covered, and measuring that would only produce a false failure.
DOCUMENTATION_PASS = ARGV.include?("--dry-run")

# Nothing is executed on the documentation pass, so nothing would be covered:
# measuring it would overwrite the real report with an empty one.
unless DOCUMENTATION_PASS
  require "simplecov"

  SimpleCov.start "rails" do
    enable_coverage :branch

    # Each parallel worker writes its own result and SimpleCov merges them, so
    # the 90% gate is measured against the whole suite rather than one shard.
    command_name "rspec#{ENV.fetch("TEST_ENV_NUMBER", nil)}"
    merging true
    merge_timeout 600

    minimum_coverage line: 90, branch: 80 unless LIVE_CABLE_PASS

    # Excluded because they hold no logic of our own: the specs themselves,
    # framework configuration and the generated schema files.
    skip "/spec/"
    skip "/config/"
    skip "/db/"

    group "Models", "app/models"
    group "Controllers", "app/controllers"
    group "Jobs", "app/jobs"
    group "Views", "app/views"
    group "Helpers", "app/helpers"
  end
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

  # The screenshot spec exists to produce README images, not to verify
  # behaviour, so it stays out of the default run.
  config.filter_run_excluding :screenshots if ENV["SCREENSHOTS"].to_s.empty?

  # Delivery over a real websocket needs Solid Cable rather than the in-memory
  # test adapter, so those examples run only in the live pass.
  config.filter_run_excluding :live unless LIVE_CABLE_PASS
  config.filter_run_including live: true if LIVE_CABLE_PASS
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.warnings = false

  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end
