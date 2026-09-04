# The single definition of the verification pipeline.
#
# Run it with bin/ci from the host (which executes it inside the container),
# or with bin/ci-run from inside a container that already has the gems.

CI.run do
  step "Database: prepare test schema", "bin/rails db:test:prepare"

  step "Style: Ruby", "bin/rubocop --parallel"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap audit", "bin/importmap audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  # SimpleCov enforces the 90% minimum and fails the process when coverage
  # drops below it, so the suite is also the coverage gate.
  step "Tests: RSpec", "bundle exec rspec"

  # A second, much smaller pass with Solid Cable in place of the in-memory
  # test adapter, so the live updates are proven to reach a real browser over
  # a real websocket rather than only to have been broadcast.
  step "Tests: live updates", "CABLE_ADAPTER=solid_cable bundle exec rspec --tag live"
end
