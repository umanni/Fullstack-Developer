#!/usr/bin/env bash
# Runs the seeds. Idempotent: running it twice changes nothing, and it puts
# back anything that was deleted while clicking around.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

require_running web
step "Seeding"
rails_exec ./bin/rails db:seed
ok "Seeded."
