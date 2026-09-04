#!/usr/bin/env bash
# Throws the environment away and builds it again: containers, the data volume
# and every database. Everything in development PostgreSQL is lost.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
DEVOPS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_docker

step "Removing containers and the data volume"
compose down --volumes --remove-orphans
ok "Previous environment removed."

"${DEVOPS}/app/setup.sh" "$@"
