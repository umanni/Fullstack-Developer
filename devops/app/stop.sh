#!/usr/bin/env bash
# Stops every container. The data volume is left alone; devops/app/reset.sh is
# what removes it.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

require_docker
step "Stopping"
compose down
ok "Stopped."
