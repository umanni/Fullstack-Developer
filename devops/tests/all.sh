#!/usr/bin/env bash
# Full verification: lint, security analysis and the test suite.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
DEVOPS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"${DEVOPS}/rails/lint.sh"
"${DEVOPS}/rails/security.sh"
"${DEVOPS}/rails/test.sh" "$@"
ok "All checks passed."
