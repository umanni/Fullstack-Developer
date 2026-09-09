#!/usr/bin/env bash
# Prepares the environment from a clean checkout: .env, images, the four
# databases, and the demonstration accounts.
#
#   devops/app/setup.sh              # everything
#   devops/app/setup.sh --no-seed    # without the demonstration accounts
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

SEED=true
[[ "${1:-}" == "--no-seed" ]] && SEED=false

require_docker

step "Environment file"
if [[ -f .env ]]; then
  log ".env already exists, leaving it untouched."
else
  cp .env.example .env
  ok "Created .env from .env.example."
fi

step "Building images"
compose build

step "Starting PostgreSQL"
compose up --detach --wait postgres

step "Preparing databases"
# db:prepare creates and migrates all four: primary, cache, queue and cable.
compose run --rm --no-deps web ./bin/rails db:prepare

if [[ "${SEED}" == true ]]; then
  step "Seeding"
  compose run --rm --no-deps web ./bin/rails db:seed
fi

step "Starting the full stack"
compose up --detach --wait

ok "Ready. The application is at http://localhost:${WEB_PORT:-3000}"
log "Logs: devops/rails/logs.sh   Tests: bin/test   Console: devops/rails/console.sh"
