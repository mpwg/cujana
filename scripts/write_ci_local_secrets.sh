#!/usr/bin/env bash
set -euo pipefail

root="${1:-}"
if [[ -z "$root" ]]; then
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel)"
  else
    root="$(pwd)"
  fi
fi

secrets_path="$root/Configuration/LocalSecrets.xcconfig"
mkdir -p "$(dirname "$secrets_path")"

cat >"$secrets_path" <<XCCONFIG
// Von CI erzeugt. Nicht committen.
APPLE_DEVELOPER_TEAM_ID = ${APPLE_DEVELOPER_TEAM_ID:-}
CUJANA_SENTRY_DSN = ${CUJANA_SENTRY_DSN:-}
CUJANA_TELEMETRY_APP_ID = ${CUJANA_TELEMETRY_APP_ID:-}
POLLENINFORMATION_API_KEY = ${POLLENINFORMATION_API_KEY:-}
XCCONFIG
