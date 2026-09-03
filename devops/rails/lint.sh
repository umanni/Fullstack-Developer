#!/usr/bin/env bash
# RuboCop. Pass -a or -A to autocorrect.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
rails_exec ./bin/rubocop "$@"
