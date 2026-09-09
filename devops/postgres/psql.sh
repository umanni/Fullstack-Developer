#!/usr/bin/env bash
# Interactive psql against the development database.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
require_running postgres
compose exec postgres psql -U "${POSTGRES_USER:-user_management}" -d "${POSTGRES_DB:-user_management_development}" "$@"
