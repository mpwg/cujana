# Release-Prozess

Dieser Prozess ist von Symi übernommen und auf Cujana angepasst. Releases sind bewusst manuell: Kein TestFlight- oder App-Store-Workflow läuft automatisch durch Pushes, Merges oder Tags. Distribution startet ausschließlich in GitHub Actions per `workflow_dispatch`.

## Branching

- `main` ist der Produktionsstand und wird erst nach erfolgreichem App-Store-Release aktualisiert.
- `develop` ist optional für laufende Entwicklung.
- `release/*` ist für Release-Vorbereitung, TestFlight und App-Store-Upload.
- Release-Branch-Namen enthalten keine Versionsnummer. Die Version kommt aus der `MARKETING_VERSION` im Xcode-Projekt und aus dem manuellen Workflow-Input.
- Git-Tags dokumentieren nur ausgelieferte Stände. Sie lösen keinen Release-Workflow aus.

## Release vorbereiten

Der Standardweg ist das Vorbereitungsskript:

```bash
scripts/prepare_release.sh 1.0.0 release/next
```

Das Skript erstellt oder öffnet den Release-Branch, setzt die `MARKETING_VERSION`, prüft Metadaten und Screenshots und führt die lokalen Release-Gates aus. Für schnelle Vorbereitungsrunden können die schweren Gates bewusst übersprungen werden:

```bash
SKIP_TESTS=1 SKIP_SCREENSHOTS=1 scripts/prepare_release.sh 1.0.0 release/next
```

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

4. Screenshots und Metadaten vorbereiten:

   - Metadaten liegen unter `fastlane/metadata`
   - Screenshots liegen unter `fastlane/screenshots/ios`
   - beide Verzeichnisse müssen versioniert und committed sein

5. Lokale Vorab-Prüfungen ausführen:

   ```bash
   make architecture-check
   make test
   bundle exec fastlane ios validate_screenshot_seed
   bundle exec fastlane ios verify_release version:1.0.0
   ```

6. Änderungen committen und Branch pushen:

   ```bash
   git status
   git add Cujana.xcodeproj fastlane docs README.md
   git commit -m "Release vorbereiten"
   git push -u origin release/next
   ```

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
- Branch: nur `release/*`
- Pflicht-Input: `changelog`
- Fastlane-Lane: `bundle exec fastlane ios beta`

Der Workflow bricht ab, wenn er nicht auf einem `release/*` Branch gestartet wird, der Changelog leer ist oder erforderliche Release-Secrets fehlen.

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
3. Branch `release/next` auswählen.
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

Das Skript prüft einen sauberen Arbeitsbaum, validiert die `MARKETING_VERSION`, merged den Release-Branch in `main`, pusht `main`, erstellt und pusht das Tag `v1.0.0` und löscht den Release-Branch lokal sowie auf `origin`.

Manuell entspricht das diesen Schritten:

1. Release-Branch in `main` mergen:

   ```bash
   git checkout main
   git pull
   git merge --no-ff release/next
   git push origin main
   ```

2. Git-Tag lokal erstellen und pushen:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. Release-Branch löschen:

   ```bash
   git push origin --delete release/next
   git branch -d release/next
   ```
