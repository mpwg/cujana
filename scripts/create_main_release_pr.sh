#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Verwendung:
  scripts/create_main_release_pr.sh VERSION [release/branch] [pr/branch]

Beispiel:
  scripts/create_main_release_pr.sh 1.0.0 release/next main-sync/next

Erstellt aus dem Release-Branch einen separaten PR-Branch gegen main. Der
PR-Branch übernimmt die Release-Änderungen, setzt fastlane/screenshots/ios aber
auf den main-Zustand zurück, damit App-Store-Screenshots nicht nach main kommen.

Voraussetzung: GitHub CLI (`gh`) ist installiert und authentifiziert.
USAGE
}

version="${1:-}"
release_branch="${2:-release/next}"
pr_branch="${3:-main-sync/${release_branch#release/}}"
base_branch="main"
base_ref="origin/$base_branch"

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

if [[ "$pr_branch" == "$release_branch" ]]; then
  echo "FEHLER: PR-Branch darf nicht identisch mit dem Release-Branch sein." >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "FEHLER: GitHub CLI 'gh' ist nicht installiert oder nicht im PATH." >&2
  exit 1
fi

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "FEHLER: Dieses Skript muss innerhalb eines Git-Repositories laufen." >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "FEHLER: Arbeitsbaum ist nicht sauber. Bitte Release-Artefakte zuerst committen." >&2
  git status --short >&2
  exit 1
fi

git fetch origin "$base_branch"

if ! git show-ref --verify --quiet "refs/heads/$release_branch"; then
  git fetch origin "$release_branch:$release_branch"
fi

if ! git ls-tree -r --name-only "$release_branch" -- fastlane/screenshots/ios | grep -q '\.png$'; then
  echo "FEHLER: $release_branch enthält keine eingecheckten PNG-Screenshots unter fastlane/screenshots/ios." >&2
  exit 1
fi

git checkout -B "$pr_branch" "$release_branch"

if git ls-tree -r --name-only "$base_ref" -- fastlane/screenshots/ios | grep -q .; then
  git checkout "$base_ref" -- fastlane/screenshots/ios
else
  git rm -r --quiet --ignore-unmatch fastlane/screenshots/ios
fi

git add -A -- fastlane/screenshots/ios 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "Main-PR ohne Release-Screenshots vorbereiten"
fi

if git diff --name-only "$base_ref"...HEAD -- fastlane/screenshots/ios | grep -q .; then
  echo "FEHLER: PR-Branch enthält weiterhin Screenshot-Änderungen gegenüber $base_branch:" >&2
  git diff --name-only "$base_ref"...HEAD -- fastlane/screenshots/ios >&2
  exit 1
fi

git push --force-with-lease -u origin "$pr_branch"

title="Release $version"
body=$(cat <<EOF
Bereitet Release $version für main vor.

Hinweis:
- App-Store-Screenshots bleiben ausschließlich auf $release_branch.
- Dieser PR-Branch enthält keine Änderungen unter fastlane/screenshots/ios gegenüber $base_branch.
EOF
)

if gh pr view "$pr_branch" --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" >/dev/null 2>&1; then
  gh pr edit "$pr_branch" --base "$base_branch" --title "$title" --body "$body"
else
  gh pr create --base "$base_branch" --head "$pr_branch" --title "$title" --body "$body"
fi

echo "PR-Branch $pr_branch ist bereit und enthält keine Screenshot-Änderungen gegen $base_branch."
