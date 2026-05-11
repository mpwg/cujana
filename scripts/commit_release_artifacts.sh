#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Verwendung:
  scripts/commit_release_artifacts.sh VERSION [release/branch]

Beispiel:
  scripts/commit_release_artifacts.sh 1.0.0 release/next

Commitet Release-Artefakte auf dem Release-Branch. App-Store-Screenshots unter
fastlane/screenshots/ios müssen vorhanden sein und werden mit eingecheckt.
USAGE
}

version="${1:-}"
release_branch="${2:-release/next}"

if [[ "$version" == "-h" || "$version" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "$version" ]]; then
  usage >&2
  exit 2
fi

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "FEHLER: VERSION muss das Format X.Y.Z haben, erhalten: $version" >&2
  exit 2
fi

if [[ "$release_branch" != release/* ]]; then
  echo "FEHLER: Release-Branch muss mit release/ beginnen, erhalten: $release_branch" >&2
  exit 2
fi

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "FEHLER: Dieses Skript muss innerhalb eines Git-Repositories laufen." >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != "$release_branch" ]]; then
  echo "FEHLER: Bitte zuerst auf $release_branch wechseln. Aktueller Branch: $current_branch" >&2
  exit 1
fi

if [[ ! -d "fastlane/screenshots/ios" ]]; then
  echo "FEHLER: fastlane/screenshots/ios fehlt. Erzeuge Screenshots mit: bundle exec fastlane ios sync_screenshots pages:all" >&2
  exit 1
fi

if ! find fastlane/screenshots/ios -type f -name '*.png' | grep -q .; then
  echo "FEHLER: fastlane/screenshots/ios enthält keine PNG-Screenshots." >&2
  exit 1
fi

bundle exec fastlane ios verify_release version:"$version"

git add \
  .gitignore \
  Cujana.xcodeproj \
  README.md \
  docs \
  fastlane/Fastfile \
  fastlane/README.md \
  fastlane/metadata \
  fastlane/screenshots/ios \
  scripts

missing_tracked_screenshot=0
while IFS= read -r screenshot; do
  if ! git ls-files --error-unmatch "$screenshot" >/dev/null 2>&1; then
    echo "FEHLER: Screenshot ist nicht im Git-Index: $screenshot" >&2
    missing_tracked_screenshot=1
  fi
done < <(find fastlane/screenshots/ios -type f -name '*.png' | sort)

if [[ "$missing_tracked_screenshot" == "1" ]]; then
  exit 1
fi

if git diff --cached --quiet; then
  echo "Keine Release-Änderungen zum Committen gefunden."
  exit 0
fi

git commit -m "Release $version vorbereiten"

echo "Release-Artefakte inklusive Screenshots auf $release_branch committed."
