# ADR-0009: GitHub-Workflows an Symi ausrichten

Status: Akzeptiert  
Datum: 2026-05-08

## Kontext

Symi trennt normale iOS-CI, CodeQL und manuelle Release-Uploads in eigene GitHub-Workflows. Cujana hatte dagegen einen Guardrail-Workflow, der Architekturprüfung, SwiftLint und Catalyst-Tests zusammen ausführte. Dadurch war nicht klar, welche Checks fachliche Architekturregeln sind und welche Checks normale iOS-CI sind.

Cujana nutzt andere Schemes, andere UI-Testnamen und einen anderen fastlane-Fastfile als Symi. Ein direktes Kopieren der Symi-Workflows würde deshalb falsche Projektpfade, falsche Testbezeichner und teilweise unnötige Secrets erzwingen.

## Entscheidung

Der Guardrail-Workflow prüft nur noch `scripts/check_architecture.sh`.

Ein neuer `ios-ci`-Workflow übernimmt SwiftLint, Catalyst-Unit-Tests, optionale iPhone-Unit-Tests und einen kleinen UI-Smoke-Test. Der Catalyst-Job verwendet weiterhin `scripts/run_xcode_tests.sh`, weil dieses Skript bereits die funktionierende Mac-Catalyst-Teststrategie für `Cujana-UnitTests` kapselt. iPhone- und UI-Smoke-Jobs laufen nicht auf Pull Requests, sondern nur bei Pushes auf `main` oder manuellem Start.

Ein neuer CodeQL-Workflow baut die `Cujana`-App manuell mit dem bestehenden App-Scheme und analysiert Swift-Code auf Release-Branches oder per manuellem Start.

Die neuen TestFlight- und App-Store-Workflows verwenden die vorhandenen fastlane-Lanes `beta`, `verify_release`, `ensure_version_not_released` und `release`. Sie laufen nur manuell. TestFlight validiert `main` oder Release-Branches, App-Store-Uploads validieren Release-Branches sowie die Secrets, die der Cujana-Fastfile tatsächlich benötigt. Symis Sentry- und Telemetrie-Secrets werden nicht übernommen, weil Cujana sie nicht verwendet.

## Erforderliche GitHub-Secrets

Für `testflight.yml` und `appstore.yml` müssen diese Repository-Secrets vorhanden sein:

- `APPLE_DEVELOPER_TEAM_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`

Diese Secrets werden zusätzlich von den Workflows referenziert und sind je nach Match-Setup erforderlich:

- `MATCH_GIT_BRANCH`
- `MATCH_GIT_BASIC_AUTHORIZATION`

## Konsequenzen

Architekturverstöße bleiben ein schneller Ubuntu-Check. iOS-Build- und Testverantwortung liegt im `ios-ci`-Workflow, der näher an Symis Struktur liegt und zusätzliche Simulator-Abdeckung gezielt einschaltet.

Release-Uploads sind weiterhin explizite manuelle Aktionen. TestFlight kann von `main` oder `release/*` laufen; App-Store-Uploads bleiben auf `release/*` beschränkt. Fehlende Metadaten, Screenshots, Secrets oder falsche Versionsformate schlagen vor dem teuren Build fehl.

Die Workflow-Pfade müssen bei neuen Schemes, Testtargets oder Fastlane-Lanes mitgepflegt werden, sonst können relevante Änderungen zu wenig oder zu viel CI auslösen.
