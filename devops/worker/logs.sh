#!/usr/bin/env bash
# Follows the Solid Queue worker logs.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
compose logs --follow --tail="${TAIL:-200}" worker "$@"
