#!/usr/bin/env bash
# Dumps the development database to tmp/backups/.
#   devops/postgres/dump.sh [output-file]
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
require_running postgres
mkdir -p tmp/backups
target="${1:-tmp/backups/development-$(date +%Y%m%d-%H%M%S).dump}"
step "Dumping to ${target}"
compose exec -T postgres pg_dump -U "${POSTGRES_USER:-user_management}" -Fc "${POSTGRES_DB:-user_management_development}" > "${target}"
ok "Wrote ${target} ($(du -h "${target}" | cut -f1))."
