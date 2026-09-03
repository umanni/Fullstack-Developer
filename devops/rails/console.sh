#!/usr/bin/env bash
# Opens a Rails console in the running web container.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
rails_exec ./bin/rails console "$@"
