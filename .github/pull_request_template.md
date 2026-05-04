## Was wurde geändert?

Kurze Beschreibung:

## Betroffene Schichten

- [ ] App / Composition
- [ ] Features
- [ ] Domain
- [ ] Infrastructure
- [ ] DesignSystem
- [ ] Platform
- [ ] Tests
- [ ] Architektur / Build / CI

## Architektur-Check

- [ ] Ich habe `make architecture-check` lokal ausgeführt.
- [ ] Feature-Code greift nicht direkt auf Netzwerk oder Persistenz zu.
- [ ] Domain-Code importiert kein SwiftUI/UIKit/SwiftData/CoreData.
- [ ] Neue Services werden injiziert, nicht als `static let shared` genutzt.
- [ ] Neue Architekturabweichungen sind per ADR dokumentiert.

## Dependencies

- [ ] Keine neue produktive Dependency.
- [ ] Neue produktive Dependency wurde per ADR begründet.

## Tests

- [ ] Unit Tests ergänzt oder angepasst.
- [ ] UI Tests ergänzt oder bewusst nicht nötig.
- [ ] Regression Test für Bugfix vorhanden oder bewusst nicht nötig.

## Hinweise für Reviewer

Was sollte besonders geprüft werden?
