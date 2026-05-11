# ADR-0021: Unsichere Swift-Escape-Hatches verbieten

## Status

Accepted

## Kontext

Cujana nutzt Architektur-Guardrails, damit produktive Abhängigkeiten explizit
komponiert werden und Swift-Concurrency-Prüfungen wirksam bleiben. `unsafe`
Escape-Hatches wie `nonisolated(unsafe)` umgehen diese Prüfungen und können
globale Zustände verdecken.

## Entscheidung

SwiftLint verbietet `unsafe` in produktivem Swift-Code generell. Zusätzlich
verbietet eine Custom Rule gespeicherten `static var`-Zustand in App-Code,
damit neue globale mutable Services nicht an der Composition Root vorbei
entstehen. Wenn eine zukünftige Plattformintegration wirklich eine Ausnahme
benötigt, braucht sie eine kleine isolierte Adapterstelle und eine neue ADR.

Bestehende Observability-Ausgaben bleiben als reine OSLog-Fassade erhalten.
Sentry wird weiterhin über die Telemetry-Composition gestartet, aber nicht mehr
über einen global austauschbaren Sender an `AppObservability` gekoppelt.

## Konsequenzen

- Swift-Concurrency- und Memory-Safety-Prüfungen bleiben in produktivem Code
  sichtbar.
- Neue unsichere Ausnahmen fallen lokal und in CI über SwiftLint auf.
- Neuer gespeicherter globaler App-Zustand fällt lokal und in CI über
  SwiftLint auf.
- Observability kann keine testübergreifenden Senderzustände mehr leaken.
