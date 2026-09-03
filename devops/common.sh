#!/usr/bin/env bash
#
# Shared helpers for the devops scripts. Source this, do not execute it.
#
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
#
set -euo pipefail

DEVOPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${DEVOPS_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

COMPOSE_FILE_PATH="${COMPOSE_FILE_PATH:-${PROJECT_ROOT}/docker-compose.yml}"
ENV_FILE_PATH="${ENV_FILE_PATH:-${PROJECT_ROOT}/.env}"

# ── Output helpers ───────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
  CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; RESET=''
fi

log()   { echo -e "${CYAN}[app]${RESET} $*"; }
ok()    { echo -e "${GREEN}[ok]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*" >&2; }
fail()  { echo -e "${RED}[x]${RESET} $*" >&2; exit 1; }
step()  { echo -e "\n${BOLD}${CYAN}==> $*${RESET}"; }

# ── Guards ───────────────────────────────────────────────────────────────────
require_docker() {
  command -v docker >/dev/null 2>&1 || fail "Docker is not installed or not on PATH."
  docker compose version >/dev/null 2>&1 || fail "Docker Compose v2 is required."
  docker info >/dev/null 2>&1 || fail "Docker daemon is not reachable. Is it running?"
}

require_running() {
  local service="$1"
  if [[ -z "$(compose ps --quiet "${service}" 2>/dev/null)" ]]; then
    fail "Service '${service}' is not running. Start it with bin/dev."
  fi
}

# ── Compose wrapper ──────────────────────────────────────────────────────────
# Resolves the compose file and the optional env file once, so every script
# talks to the same stack.
compose() {
  local args=(compose --file "${COMPOSE_FILE_PATH}")
  [[ -f "${ENV_FILE_PATH}" ]] && args+=(--env-file "${ENV_FILE_PATH}")
  docker "${args[@]}" "$@"
}

# Runs a command inside the web container with the test environment wired up.
# Keeping RAILS_ENV=test here is what stops specs from writing into the
# development database through Faker and FactoryBot.
rails_test_exec() {
  require_running web
  compose exec -T \
    -e RAILS_ENV=test \
    -e DISABLE_SPRING=1 \
    web "$@"
}

rails_exec() {
  require_running web
  compose exec web "$@"
}
