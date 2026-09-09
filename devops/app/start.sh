#!/usr/bin/env bash
# Starts web, worker, the Tailwind watcher and PostgreSQL, and waits until they
# report healthy.
#
#   devops/app/start.sh              # in the background
#   devops/app/start.sh --attach     # in the foreground, streaming logs
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

require_docker
[[ -f .env ]] || fail "No .env found. Run devops/app/setup.sh first."

if [[ "${1:-}" == "--attach" ]]; then
  step "Starting, streaming logs"
  compose up
else
  step "Starting"
  compose up --detach --wait
  ok "Running at http://localhost:${WEB_PORT:-3000}"
fi
