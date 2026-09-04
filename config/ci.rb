# The single definition of the verification pipeline.
#
# Run it with bin/ci from the host (which executes it inside the container),
# or with bin/ci-run from inside a container that already has the gems.

require "etc"

# Four workers at most: each one needs its own set of four databases, and past
# that ceiling creating them costs more than the suite saves. The same ceiling
# as devops/rails/test-parallel.sh, which is the entrypoint a person uses, so
# the pipeline and the laptop shard the suite the same way.
workers = [Etc.nprocessors, 4].min

CI.run do
  # The base test database is still prepared on its own, because the live pass
  # below is serial and runs against it.
  step "Database: prepare test schema", "bin/rails db:test:prepare"
  step "Database: prepare #{workers} parallel test schemas",
       "bundle", "exec", "rake", "parallel:prepare[#{workers}]"

  step "Style: Ruby", "bin/rubocop --parallel"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Importmap audit", "bin/importmap audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  # SimpleCov enforces the 90% minimum and fails the process when coverage
  # drops below it, so the suite is also the coverage gate. Each worker writes
  # its own result and SimpleCov merges them, so the gate is measured against
  # the whole suite rather than one shard -- spec/spec_helper.rb sets the
  # command_name and merging that makes that true.
  step "Tests: RSpec on #{workers} workers",
       "bundle", "exec", "parallel_rspec", "-n", workers.to_s

  # A second, much smaller pass with Solid Cable in place of the in-memory
  # test adapter, so the live updates are proven to reach a real browser over
  # a real websocket rather than only to have been broadcast.
  step "Tests: live updates", "CABLE_ADAPTER=solid_cable bundle exec rspec --tag live"

  # The OpenAPI document is generated from the specs that exercise the API, so
  # regenerating it and finding a difference means the committed copy describes
  # an API that no longer exists.
  step "Docs: OpenAPI is current", "bin/openapi-current"
end
