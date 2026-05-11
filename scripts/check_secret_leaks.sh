#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    ROOT="$(git rev-parse --show-toplevel)"
  else
    ROOT="$(pwd)"
  fi
fi

cd "$ROOT"

failures=0

report_error() {
  local file="$1"
  local line="$2"
  local message="$3"
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    printf '::error file=%s,line=%s::%s\n' "$file" "$line" "$message"
  else
    printf 'ERROR %s:%s %s\n' "$file" "$line" "$message" >&2
  fi
  failures=$((failures + 1))
}

is_placeholder_or_reference() {
  local value="$1"
  local trimmed
  trimmed="$(printf '%s' "$value" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

  [[ -z "$trimmed" \
    || "$trimmed" == '$'* \
    || "$trimmed" == *'${{'* \
    || "$trimmed" == *'secrets.'* \
    || "$trimmed" == *'ENV['* \
    || "$trimmed" == *'ENV.fetch'* \
    || "$trimmed" == *'env:'* \
    || "$trimmed" =~ ^(<[^>]+>|CHANGE_ME|CHANGEME|TODO|REDACTED|redacted|dummy|example)$ ]]
}

tracked_files=()
while IFS= read -r -d '' file; do
  tracked_files+=("$file")
done < <(git ls-files -z)

if [[ " ${tracked_files[*]} " == *" Configuration/LocalSecrets.xcconfig "* ]]; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^([0-9]+):(APPLE_DEVELOPER_TEAM_ID|CUJANA_SENTRY_DSN|CUJANA_TELEMETRY_APP_ID|POLLENINFORMATION_API_KEY)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
      line_number="${BASH_REMATCH[1]}"
      setting_name="${BASH_REMATCH[2]}"
      setting_value="${BASH_REMATCH[3]}"
      if ! is_placeholder_or_reference "$setting_value"; then
        report_error "Configuration/LocalSecrets.xcconfig" "$line_number" \
          "${setting_name} must not be committed with a non-empty value. Keep local secrets out of git, logs, issues, and PRs."
      fi
    fi
  done < <(grep -nE '^[[:space:]]*(APPLE_DEVELOPER_TEAM_ID|CUJANA_SENTRY_DSN|CUJANA_TELEMETRY_APP_ID|POLLENINFORMATION_API_KEY)[[:space:]]*=' Configuration/LocalSecrets.xcconfig || true)
fi

for file in "${tracked_files[@]}"; do
  case "$file" in
    Configuration/LocalSecrets.xcconfig)
      continue
      ;;
    .git/*|.build/*|.xcode-derived-data/*|DerivedData/*|fastlane/screenshots/*)
      continue
      ;;
  esac

  while IFS= read -r line; do
    if [[ "$line" =~ ^([0-9]+):[[:space:]]*(APPLE_DEVELOPER_TEAM_ID|APP_STORE_CONNECT_KEY_ID|APP_STORE_CONNECT_ISSUER_ID|APP_STORE_CONNECT_PRIVATE_KEY|CUJANA_SENTRY_DSN|CUJANA_TELEMETRY_APP_ID|POLLENINFORMATION_API_KEY|MATCH_PASSWORD|MATCH_GIT_BASIC_AUTHORIZATION)[[:space:]]*[:=][[:space:]]*(.+)$ ]]; then
      line_number="${BASH_REMATCH[1]}"
      setting_name="${BASH_REMATCH[2]}"
      setting_value="${BASH_REMATCH[3]}"
      if ! is_placeholder_or_reference "$setting_value"; then
        report_error "$file" "$line_number" \
          "${setting_name} appears to contain a literal secret value. Reference CI secrets or environment variables instead."
      fi
    fi
  done < <(grep -nE '^[[:space:]]*(APPLE_DEVELOPER_TEAM_ID|APP_STORE_CONNECT_KEY_ID|APP_STORE_CONNECT_ISSUER_ID|APP_STORE_CONNECT_PRIVATE_KEY|CUJANA_SENTRY_DSN|CUJANA_TELEMETRY_APP_ID|POLLENINFORMATION_API_KEY|MATCH_PASSWORD|MATCH_GIT_BASIC_AUTHORIZATION)[[:space:]]*[:=][[:space:]]*.+' "$file" || true)
done

if grep -RInE '(^|[[:space:]])set[[:space:]]+(-x|-o[[:space:]]+xtrace)([[:space:]]|$)' scripts fastlane .github/workflows >/dev/null 2>&1; then
  while IFS=: read -r file line _; do
    report_error "$file" "$line" \
      "Shell xtrace is not allowed in build, release, or CI scripts because it can print secret build settings."
  done < <(grep -RInE '(^|[[:space:]])set[[:space:]]+(-x|-o[[:space:]]+xtrace)([[:space:]]|$)' scripts fastlane .github/workflows || true)
fi

if [[ "$failures" -gt 0 ]]; then
  printf '\nSecret leak check failed with %d violation(s).\n' "$failures" >&2
  exit 1
fi

echo "Secret leak check passed."
