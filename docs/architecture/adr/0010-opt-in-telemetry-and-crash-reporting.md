# ADR-0010: Opt-in-Telemetrie und Crash-Reporting

## Status

Akzeptiert

## Kontext

Cujana soll TelemetryDeck und Sentry analog zu Symi verwenden. Die App verarbeitet sensible Gesundheits- und Standortkontexte, daher dürfen Nutzungsdaten und Fehlerberichte nur nach explizitem Opt-in aktiviert werden.

Die Release-Builds benötigen eigene Secrets für Cujana:

- `CUJANA_TELEMETRY_APP_ID`
- `CUJANA_SENTRY_DSN`

Außerdem brauchen Paket-, Build- und CI-Änderungen eine dokumentierte Architekturentscheidung, weil sie die Abhängigkeiten und den Release-Pfad der App verändern.

## Entscheidung

Cujana bindet TelemetryDeck und Sentry als SwiftPM-Abhängigkeiten im App-Target ein. Beide Dienste werden über eine zentrale `AppTelemetryService`-Instanz gesteuert, die aus der App-Komposition injiziert wird. Globale Shared-Singletons werden vermieden.

Die App zeigt beim Start eine Opt-in-Abfrage. Ohne Zustimmung werden weder Sentry noch TelemetryDeck gestartet. In den Einstellungen gibt es einen Eintrag zur Verwaltung des Opt-ins; Ausschalten stoppt beide Dienste sofort.

Die Secrets werden in `Info.plist` über Build Settings gelesen:

- `SENTRY_DSN` aus `$(CUJANA_SENTRY_DSN)`
- `TELEMETRY_APP_ID` aus `$(CUJANA_TELEMETRY_APP_ID)`

fastlane und die GitHub-Release-Workflows geben diese Cujana-spezifischen Build Settings weiter. Ein Privacy Manifest beschreibt die diagnostischen Daten und die UserDefaults-Nutzung für die Opt-in-Entscheidung.

## Konsequenzen

- Telemetrie bleibt privacy-by-default und wird erst nach ausdrücklicher Zustimmung aktiviert.
- Tests und Screenshot-Läufe unterdrücken Telemetrie unabhängig vom gespeicherten Opt-in.
- Release-Umgebungen müssen `CUJANA_TELEMETRY_APP_ID` und `CUJANA_SENTRY_DSN` als Secrets bereitstellen.
- Die App-Komposition bleibt verantwortlich für langlebige Dienste und vermeidet versteckte globale Abhängigkeiten.
