#!/usr/bin/env bash
# Runs RSpec inside the web container against the test databases.
#   devops/rails/test.sh                       # whole suite
#   devops/rails/test.sh spec/models/user_spec.rb
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
step "Preparing test databases"
rails_test_exec ./bin/rails db:test:prepare
step "Running RSpec"
if [[ "$#" -gt 0 ]]; then
  rails_test_exec env SCREENSHOTS="${SCREENSHOTS:-}" bundle exec rspec "$@"
else
  rails_test_exec env SCREENSHOTS="${SCREENSHOTS:-}" bundle exec rspec
fi
