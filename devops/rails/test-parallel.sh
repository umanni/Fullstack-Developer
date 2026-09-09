#!/usr/bin/env bash
# Runs the suite across parallel workers, each with its own database.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
# Four by default rather than one per core: each worker needs its own set of
# four databases, and a 16-core machine would spend longer creating them than
# running the suite. Override with WORKERS=n.
DEFAULT_WORKERS=4
CORES="$(nproc 2>/dev/null || echo "${DEFAULT_WORKERS}")"
WORKERS="${WORKERS:-$(( CORES < DEFAULT_WORKERS ? CORES : DEFAULT_WORKERS ))}"
# `parallel:prepare` loads the schema into each worker database.
# `parallel:setup` would run db:setup instead, which also runs the seeds and
# leaves the demonstration roster sitting in every test database.
step "Preparing ${WORKERS} parallel test databases"
rails_test_exec bundle exec rake parallel:prepare["${WORKERS}"]
step "Running RSpec on ${WORKERS} workers"
rails_test_exec bundle exec parallel_rspec -n "${WORKERS}" "$@"
