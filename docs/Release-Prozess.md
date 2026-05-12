# Release-Prozess

Dieser Prozess ist von Symi übernommen und auf Cujana angepasst. Releases sind bewusst manuell: Kein TestFlight- oder App-Store-Workflow läuft automatisch durch Pushes, Merges oder Tags. Distribution startet ausschließlich in GitHub Actions per `workflow_dispatch`.

## Branching

- `main` ist der Produktionsstand und wird über einen PR ohne App-Store-Screenshots aktualisiert.
- `develop` ist optional für laufende Entwicklung.
- TestFlight kann manuell von `main` oder `release/*` gestartet werden.
- `release/*` ist für Release-Vorbereitung und App-Store-Upload. App-Store-Screenshots werden nur auf diesem Branch eingecheckt.
- Release-Branch-Namen enthalten keine Versionsnummer. Die Version kommt aus der `MARKETING_VERSION` im Xcode-Projekt und aus dem manuellen Workflow-Input.
- Git-Tags dokumentieren nur ausgelieferte Stände. Sie lösen keinen Release-Workflow aus.

## Release vorbereiten

Der Standardweg ist das Vorbereitungsskript:

```bash
scripts/prepare_release.sh 1.0.0 release/next
```

Das Skript erstellt oder öffnet den Release-Branch, setzt die `MARKETING_VERSION`, erzeugt die App-Store-Screenshots, prüft Metadaten und Screenshots und führt die lokalen Release-Gates aus. Für schnelle Vorbereitungsrunden können die schweren Gates bewusst übersprungen werden:

```bash
SKIP_TESTS=1 SKIP_SCREENSHOTS=1 scripts/prepare_release.sh 1.0.0 release/next
```

Mit `SKIP_SCREENSHOTS=1` werden keine neuen Screenshots erzeugt; dann müssen unter `fastlane/screenshots/ios` bereits gültige PNGs für alle Sprachen liegen.

Manuell entspricht das diesen Schritten:

1. Aktuellen Stand holen:

   ```bash
   git checkout main
   git pull
   ```

2. Release-Branch erstellen:

   ```bash
   git checkout -b release/next
   ```

3. Version im Xcode-Projekt setzen, zum Beispiel `1.0.0`.

   Die App-Store-Workflows erwarten das Format `X.Y.Z`. Die `MARKETING_VERSION` im Xcode-Projekt muss exakt zur späteren Workflow-Eingabe passen.

4. Metadaten vorbereiten:

   - Metadaten liegen unter `fastlane/metadata`
   - Metadaten müssen versioniert und committed sein

5. Lokale Vorab-Prüfungen ausführen und Screenshots erzeugen:

   ```bash
   make architecture-check
   make test
   bundle exec fastlane ios sync_screenshots pages:all
   bundle exec fastlane ios verify_release version:1.0.0
   ```

   `sync_screenshots` erzeugt die App-Store-PNGs unter `fastlane/screenshots/ios`; diese Dateien gehören in den Release-Commit. `validate_screenshot_seed` ist nur ein schneller Smoke-Test und schreibt höchstens einen lokalen Kontroll-Screenshot unter `fastlane/screenshots/seed-check`; dieser Lane ersetzt `sync_screenshots` nicht.

6. Release-Artefakte committen und Branch pushen:

   ```bash
   git status
   scripts/commit_release_artifacts.sh 1.0.0 release/next
   git push -u origin release/next
   ```

   Das Commit-Skript prüft `fastlane/screenshots/ios`, staged die Release-Dateien inklusive PNGs und bricht ab, wenn ein Screenshot nicht im Git-Index landet.

7. Main-PR ohne Screenshots erstellen:

   ```bash
   scripts/create_main_release_pr.sh 1.0.0 release/next
   ```

   Das PR-Skript erzeugt einen separaten Branch, standardmäßig `main-sync/next`, setzt `fastlane/screenshots/ios` dort auf den `main`-Zustand zurück und erstellt einen PR gegen `main`. Wenn der PR dennoch Screenshot-Änderungen enthalten würde, bricht das Skript ab.

## GitHub-Actions-Workflows

### iOS CI

- Datei: `.github/workflows/ios-ci.yml`
- Start: Pull Requests auf `main`, Pushes auf `main`, manueller Start
- Zweck: SwiftLint, Catalyst-Unit-Tests, iPhone-Unit-Tests und UI-Smoke
- Xcode: `26.4`

### CodeQL

- Datei: `.github/workflows/codeql.yml`
- Start: Pull Requests auf `main` mit produktiven Swift- oder Projektänderungen, Pushes und Pull Requests auf `release/**`, manueller Start
- Zweck: Swift-Codeanalyse mit manuellem App-Build

### TestFlight

- Datei: `.github/workflows/testflight.yml`
- Start: ausschließlich manuell
- Branch: `main` oder `release/*`
- Pflicht-Input: `changelog`
- Fastlane-Lane: `bundle exec fastlane ios beta`

Der Workflow bricht ab, wenn er nicht auf `main` oder einem `release/*` Branch gestartet wird, der Changelog leer ist oder erforderliche Release-Secrets fehlen.

### App Store Release

- Datei: `.github/workflows/appstore.yml`
- Start: ausschließlich manuell
- Branch: nur `release/*`
- Pflicht-Inputs: `version` und `confirm_release`
- `confirm_release` muss exakt `YES` sein
- Fastlane-Lanes:
  - `bundle exec fastlane ios verify_release version:<version>`
  - `bundle exec fastlane ios ensure_version_not_released version:<version>`
  - `bundle exec fastlane ios release version:<version>`

Der Workflow prüft vor dem Upload:

- Branch muss `release/*` sein
- `confirm_release` muss exakt `YES` sein
- Version darf nicht leer sein und muss `X.Y.Z` entsprechen
- Version muss zur `MARKETING_VERSION` im Xcode-Projekt passen
- Version darf in App Store Connect noch nicht existieren
- `fastlane/metadata` muss Dateien enthalten
- `fastlane/screenshots/ios` muss PNG-Screenshots enthalten
- erforderliche Release-Secrets müssen vorhanden sein

Die App wird nach App Store Connect hochgeladen, aber nicht automatisch zur Prüfung eingereicht und nicht automatisch veröffentlicht.

## TestFlight

1. In GitHub Actions den Workflow `TestFlight` öffnen.
2. `Run workflow` wählen.
3. Branch `main` oder `release/next` auswählen.
4. `changelog` ausfüllen.
5. Workflow starten.
6. Build in TestFlight prüfen:

   - Build ist erfolgreich verarbeitet
   - Installation funktioniert
   - Kernflows laufen
   - Screenshots und Metadaten passen zum Release

## App Store

1. In GitHub Actions den Workflow `App Store Release` öffnen.
2. `Run workflow` wählen.
3. Branch `release/next` auswählen.
4. `version` exakt wie im Xcode-Projekt eingeben, zum Beispiel `1.0.0`.
5. `confirm_release` exakt mit `YES` ausfüllen.
6. Workflow starten.
7. Nach erfolgreichem Upload die finale Einreichung manuell in App Store Connect durchführen.

## Release-Secrets

Erforderliche GitHub-Secrets:

- `APPLE_DEVELOPER_TEAM_ID`
- `POLLENINFORMATION_API_KEY`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`

Je nach Match-Setup zusätzlich erforderlich:

- `MATCH_GIT_BRANCH`
- `MATCH_GIT_BASIC_AUTHORIZATION`

## Nach erfolgreichem App-Store-Upload

Der Standardweg ist das Abschlussskript:

```bash
scripts/finalize_release.sh 1.0.0 release/next
```

Das Skript prüft einen sauberen Arbeitsbaum, validiert die `MARKETING_VERSION`, stellt eingecheckte Release-Screenshots sicher, erstellt und pusht das Tag `v1.0.0` auf dem Release-Branch und löscht den Release-Branch lokal sowie auf `origin`. Es merged nicht nach `main`.

Manuell entspricht das diesen Schritten:

1. Main-PR ohne Screenshots prüfen und mergen.

   Der PR wird mit `scripts/create_main_release_pr.sh` erzeugt. Vor dem Merge muss der PR weiterhin keine Änderungen unter `fastlane/screenshots/ios` zeigen.

2. Git-Tag auf dem Release-Branch erstellen und pushen:

   ```bash
   git checkout release/next
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. Release-Branch löschen:

   ```bash
   git checkout main
   git pull --ff-only
   git push origin --delete release/next
   git branch -D release/next
   ```
