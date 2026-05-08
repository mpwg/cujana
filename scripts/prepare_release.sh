#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Verwendung:
  scripts/prepare_release.sh VERSION [release/branch]

Beispiel:
  scripts/prepare_release.sh 1.0.0 release/next

Erstellt oder öffnet den Release-Branch, setzt MARKETING_VERSION im
Xcode-Projekt, prüft Release-Artefakte und führt die lokalen Release-Gates aus.

Umgebung:
  SKIP_TESTS=1        make test überspringen.
  SKIP_SCREENSHOTS=1  fastlane Screenshot-Seed-Validierung überspringen.
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

if [[ -n "$(git status --porcelain)" ]]; then
  echo "FEHLER: Arbeitsbaum ist nicht sauber. Bitte Änderungen committen oder stagen, bevor der Release-Branch vorbereitet wird." >&2
  git status --short >&2
  exit 1
fi

if git show-ref --verify --quiet "refs/heads/$release_branch"; then
  git checkout "$release_branch"
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [[ -n "$upstream" ]]; then
    git pull --ff-only
  fi
else
  git checkout main
  git pull --ff-only
  git checkout -b "$release_branch"
fi

make architecture-check

/usr/bin/perl -0pi -e "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = $version;/g" Cujana.xcodeproj/project.pbxproj

if [[ ! -d "fastlane/metadata" ]]; then
  echo "FEHLER: fastlane/metadata fehlt." >&2
  exit 1
fi

if [[ ! -d "fastlane/screenshots/ios" ]]; then
  echo "FEHLER: fastlane/screenshots/ios fehlt." >&2
  exit 1
fi

if ! find fastlane/metadata -type f | grep -q .; then
  echo "FEHLER: fastlane/metadata enthält keine Dateien." >&2
  exit 1
fi

if ! find fastlane/screenshots/ios -type f -name '*.png' | grep -q .; then
  echo "FEHLER: fastlane/screenshots/ios enthält keine PNG-Screenshots." >&2
  exit 1
fi

if [[ "${SKIP_TESTS:-0}" != "1" ]]; then
  make test
else
  echo "Überspringe make test wegen SKIP_TESTS=1."
fi

if [[ "${SKIP_SCREENSHOTS:-0}" != "1" ]]; then
  bundle exec fastlane ios validate_screenshot_seed
else
  echo "Überspringe Screenshot-Seed-Validierung wegen SKIP_SCREENSHOTS=1."
fi

bundle exec fastlane ios verify_release version:"$version"

cat <<EOF

Release-Vorbereitung abgeschlossen.

Nächste Schritte:
  git status
  git add Cujana.xcodeproj fastlane docs README.md
  git commit -m "Release $version vorbereiten"
  git push -u origin $release_branch

Danach in GitHub Actions den Workflow "TestFlight" auf $release_branch starten.
EOF
