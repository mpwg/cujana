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

report_warning() {
  local message="$1"
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    printf '::warning::%s\n' "$message"
  else
    printf 'WARNING %s\n' "$message" >&2
  fi
}

is_test_file() {
  local file="$1"
  [[ "$file" == *Tests/* || "$file" == *UITests/* || "$file" == *Test.swift || "$file" == *Tests.swift ]]
}

is_allowed_uikit_path() {
  local file="$1"
  [[ "$file" == *"/Platform/"* \
    || "$file" == *"/UIKitAdapters/"* \
    || "$file" == *"/AppleFrameworkAdapters/"* \
    || "$file" == *"/Infrastructure/"* \
    || "$file" == *"Tests/"* \
    || "$file" == *"UITests/"* ]]
}

is_allowed_swiftdata_path() {
  local file="$1"
  [[ "$file" == Cujana/Infrastructure/Persistence/* \
    || "$file" == CujanaTests/* \
    || "$file" == CujanaUITests/* ]]
}

is_allowed_userdefaults_path() {
  local file="$1"
  [[ "$file" == Cujana/Infrastructure/Persistence/* \
    || "$file" == CujanaTests/* \
    || "$file" == CujanaUITests/* ]]
}

scan_pattern() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  while IFS=: read -r match_file line _; do
    [[ -z "${match_file:-}" ]] && continue
    report_error "$match_file" "$line" "$message"
  done < <(grep -nHE "$pattern" "$file" || true)
}

swift_files=()
while IFS= read -r file; do
  swift_files+=("$file")
done < <(
  find . -type f -name '*.swift' \
    ! -path './.build/*' \
    ! -path './.swiftpm-package-cache/*' \
    ! -path './.xcode-derived-data/*' \
    ! -path './.xcode-derived-data-*/*' \
    ! -path './.xcode-source-packages/*' \
    ! -path './DerivedData/*' \
    ! -path './Carthage/*' \
    ! -path './Pods/*' \
    | sort
)

if [[ ${#swift_files[@]} -eq 0 ]]; then
  echo "No Swift files found. Architecture guardrails are installed and ready."
else
  for file in "${swift_files[@]}"; do
    normalized="${file#./}"

    if [[ "$normalized" == Cujana/* || "$normalized" == CujanaTests/* || "$normalized" == CujanaUITests/* ]]; then
      if ! is_allowed_swiftdata_path "$normalized"; then
        scan_pattern "$file" '(^import[[:space:]]+SwiftData$|@Model\b|\b(ModelContainer|ModelContext)\b)' \
          "SwiftData APIs are only allowed in Cujana/Infrastructure/Persistence or ADR-approved test code."
      fi

      if ! is_allowed_userdefaults_path "$normalized"; then
        scan_pattern "$file" '\bUserDefaults\.standard\b' \
          "UserDefaults.standard is only allowed behind stores in Cujana/Infrastructure/Persistence."
      fi
    fi

    if [[ "$normalized" == Cujana/Domain/* ]]; then
      scan_pattern "$file" '^import[[:space:]]+(SwiftUI|UIKit|SwiftData|CoreData)$' \
        "Domain must not import UI or persistence frameworks. Move technical details to Infrastructure/Platform."
      scan_pattern "$file" '\b(URLSession|ModelContext|NSManagedObjectContext|UserDefaults\.standard)\b' \
        "Domain must not use network or persistence APIs directly. Depend on protocols and value types."
    fi

    if [[ "$normalized" == Cujana/Features/* ]]; then
      scan_pattern "$file" '\bURLSession(\.shared)?\b' \
        "Features must not use URLSession directly. Use a UseCase or Repository protocol."
      scan_pattern "$file" '\b(UserDefaults\.standard|ModelContext|NSManagedObjectContext|FileManager\.default)\b|@Query' \
        "Features must not access persistence directly. Use a Repository protocol."
      scan_pattern "$file" '^import[[:space:]]+(SwiftData|CoreData)$' \
        "Features must not import persistence frameworks directly without an ADR-backed exception."
    fi

    if [[ "$normalized" == Cujana/Features/*View.swift || "$normalized" == Cujana/Features/*/*View.swift ]]; then
      scan_pattern "$file" '\b(URLSession|UserDefaults\.standard|ModelContext|NSManagedObjectContext|FileManager\.default)\b|@Query' \
        "Views must stay declarative. Move side effects to ViewModel/UseCase/Repository."
    fi

    if [[ "$normalized" == Cujana/Infrastructure/* ]]; then
      scan_pattern "$file" '^import[[:space:]]+CujanaFeatures\b|^import[[:space:]]+Features\b' \
        "Infrastructure must not depend on Features. Invert the dependency through Domain protocols."
    fi

    if grep -nE '^import[[:space:]]+UIKit$' "$file" >/tmp/cujana-uikit-matches 2>/dev/null; then
      if ! is_allowed_uikit_path "$normalized"; then
        while IFS=: read -r _ line _; do
          report_error "$file" "$line" \
            "UIKit imports are only allowed in Platform, explicit adapters, Infrastructure, or tests. Prefer SwiftUI in feature UI."
        done </tmp/cujana-uikit-matches
      fi
    fi

    scan_pattern "$file" '\b(class|struct|actor)\s+[A-Z][A-Za-z0-9]*Manager\b' \
      "Avoid vague Manager types. Use Repository, UseCase, Router, Store, Client, Adapter, or a domain-specific name."

    if ! is_test_file "$normalized"; then
      scan_pattern "$file" '\bstatic[[:space:]]+let[[:space:]]+shared\b' \
        "Avoid global shared singletons. Inject dependencies from App/Composition."
      scan_pattern "$file" '(try!|as!)' \
        "Avoid try! and as!. Handle errors and casts explicitly."
    fi

    if is_test_file "$normalized"; then
      if grep -qE '^import[[:space:]]+Testing$' "$file" && grep -qE '^import[[:space:]]+XCTest$' "$file"; then
        report_error "$file" "1" \
          "Do not mix Swift Testing and XCTest APIs in the same test file. Use Swift Testing for unit tests and XCTest for UI/performance tests."
      fi
    fi
  done
fi

# Dependency / architecture rule changes should be accompanied by an ADR.
# This only runs when a git comparison base is available, for example in CI with fetch-depth: 0.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  base_ref=""
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    base_ref="origin/main"
  elif git rev-parse --verify main >/dev/null 2>&1; then
    base_ref="main"
  fi

  if [[ -n "$base_ref" ]]; then
    changed_files="$(git diff --name-only "$base_ref"...HEAD 2>/dev/null || true)"
    if [[ -n "$changed_files" ]]; then
      dependency_or_rule_change="$(printf '%s\n' "$changed_files" | grep -E '(^Package\.swift$|\.xcodeproj/project\.pbxproj$|^\.swiftlint\.yml$|^\.cujana/architecture\.yml$|^scripts/check_architecture\.sh$|^\.github/workflows/)' || true)"
      adr_change="$(printf '%s\n' "$changed_files" | grep -E '^docs/architecture/adr/[0-9]{4}-.+\.md$' || true)"
      if [[ -n "$dependency_or_rule_change" && -z "$adr_change" ]]; then
        report_error "docs/architecture/adr" "1" \
          "Dependency, build, CI, lint, or architecture-rule changes require an ADR in docs/architecture/adr/."
      fi
    fi
  else
    report_warning "No git base ref found; skipping ADR change detection."
  fi
fi

rm -f /tmp/cujana-uikit-matches

if [[ "$failures" -gt 0 ]]; then
  printf '\nArchitecture check failed with %d violation(s).\n' "$failures" >&2
  exit 1
fi

echo "Architecture check passed."
