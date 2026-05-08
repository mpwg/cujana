#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Verwendung:
  scripts/finalize_release.sh VERSION [release/branch]

Beispiel:
  scripts/finalize_release.sh 1.0.0 release/next

Merged den Release-Branch in main, pusht main, erstellt und pusht das
Release-Tag und löscht den lokalen und entfernten Release-Branch.

Nur ausführen, nachdem der App-Store-Upload für dieselbe Version erfolgreich war.
USAGE
}

version="${1:-}"
release_branch="${2:-release/next}"
tag="v$version"

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
  echo "FEHLER: Arbeitsbaum ist nicht sauber. Bitte zuerst committen oder aufräumen." >&2
  git status --short >&2
  exit 1
fi

if ! git show-ref --verify --quiet "refs/heads/$release_branch"; then
  git fetch origin "$release_branch:$release_branch"
fi

if git rev-parse --verify "$tag" >/dev/null 2>&1; then
  echo "FEHLER: Tag $tag existiert lokal bereits." >&2
  exit 1
fi

if git ls-remote --exit-code --tags origin "$tag" >/dev/null 2>&1; then
  echo "FEHLER: Tag $tag existiert auf origin bereits." >&2
  exit 1
fi

git checkout "$release_branch"
project_version="$(xcodebuild -project Cujana.xcodeproj -scheme Cujana -configuration Release -showBuildSettings -destination 'generic/platform=iOS' 2>/dev/null | awk '/MARKETING_VERSION =/ { print $3; exit }')"

if [[ "$project_version" != "$version" ]]; then
  echo "FEHLER: MARKETING_VERSION ist $project_version, erwartet $version." >&2
  exit 1
fi

git checkout main
git pull --ff-only
git merge --no-ff "$release_branch" -m "Release $version"
git push origin main
git tag "$tag"
git push origin "$tag"
git push origin --delete "$release_branch"
git branch -d "$release_branch"

echo "Release $version abgeschlossen und als $tag getaggt."
