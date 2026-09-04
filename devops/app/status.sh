#!/usr/bin/env bash
# What is running, and whether it is healthy.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

require_docker
step "Services"
compose ps

step "Health check"
if curl -sf "http://localhost:${WEB_PORT:-3000}/up" >/dev/null; then
  ok "The application answers on http://localhost:${WEB_PORT:-3000}"
else
  warn "The application is not answering on http://localhost:${WEB_PORT:-3000}"
fi
