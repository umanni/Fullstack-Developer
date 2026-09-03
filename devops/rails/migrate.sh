#!/usr/bin/env bash
# Runs pending migrations across every configured database.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
step "Migrating databases"
rails_exec ./bin/rails db:migrate "$@"
ok "Migrations applied."
