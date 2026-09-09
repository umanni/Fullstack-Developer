#!/usr/bin/env bash
# Restarts one service, or all of them.
#
#   devops/app/restart.sh            # everything
#   devops/app/restart.sh web        # one service
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

require_docker
step "Restarting ${1:-every service}"
compose restart "$@"
compose ps
