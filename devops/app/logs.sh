#!/usr/bin/env bash
# Follows the logs of every service at once. For one service, use the wrapper
# next to it: devops/rails/logs.sh, devops/worker/logs.sh, devops/postgres/logs.sh.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
compose logs --follow --tail="${TAIL:-200}" "$@"
