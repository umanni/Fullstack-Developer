#!/usr/bin/env bash
# Follows the web server logs. Pass extra docker compose logs flags if needed.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
compose logs --follow --tail="${TAIL:-200}" web "$@"
