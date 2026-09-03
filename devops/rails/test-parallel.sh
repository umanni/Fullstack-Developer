#!/usr/bin/env bash
# Runs the suite across parallel workers, each with its own database.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
WORKERS="${WORKERS:-$(nproc 2>/dev/null || echo 4)}"
step "Creating ${WORKERS} parallel test databases"
rails_test_exec bundle exec rake parallel:setup["${WORKERS}"]
step "Running RSpec on ${WORKERS} workers"
rails_test_exec bundle exec parallel_rspec -n "${WORKERS}" "$@"
