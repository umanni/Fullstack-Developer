#!/usr/bin/env bash
# Static security analysis: Brakeman plus a dependency audit.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
status=0
step "Brakeman"
rails_exec ./bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error || status=1
step "Bundler Audit"
rails_exec ./bin/bundler-audit || status=1
step "Importmap audit"
rails_exec ./bin/importmap audit || status=1
if [[ "${status}" -ne 0 ]]; then
  fail "Security checks reported findings."
fi
ok "No security findings."
