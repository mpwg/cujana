# Cujana

Cujana ist eine **iOS-App für iPhone und iPad mit Mac-Catalyst-Unterstützung**. Das Repository startet bewusst mit einer klaren Architektur, bevor Implementierungsdetails wachsen.

## Architektur

Das verbindliche Architekturkonzept liegt hier:

- [docs/architecture/README.md](docs/architecture/README.md) – Architektur, Schichten, Abhängigkeiten, Teststrategie
- [docs/architecture/enforcement.md](docs/architecture/enforcement.md) – automatische Regeln, CI, Review-Gates
- [docs/architecture/adr](docs/architecture/adr) – Architecture Decision Records
- [docs/mvp-quality-gate.md](docs/mvp-quality-gate.md) – Abschlussprüfung für MVP-Flow, Architektur und Qualität

## Grundsatz

> Einfachheit vor Framework-Sammlung. Jede neue Abstraktion braucht einen sichtbaren Nutzen.

Cujana verwendet eine **SwiftUI-first, iOS-fokussierte, modular-monolithische Architektur**:

- ein Produkt, eine Plattformfamilie: iOS/iPadOS inklusive Mac Catalyst
- klare Feature-Slices statt technischer Monsterordner
- Domain-Logik ohne UI-, Netzwerk- oder Persistenz-Abhängigkeit
- Infrastruktur nur hinter Protokollen
- automatische Architekturprüfungen in CI

## Lokale Checks

```bash
make architecture-check
```

Tests laufen lokal über dasselbe Unit-Test-Scheme wie im CI-Guardrail:

```bash
make test
```

oder direkt:

```bash
./scripts/check_architecture.sh
```

## Releases

Der manuelle Release-Prozess mit Branch-Regeln, TestFlight- und App-Store-Workflows liegt in [docs/Release-Prozess.md](docs/Release-Prozess.md).

## Neue Architekturentscheidungen

Für Änderungen an Plattform, Schichten, Persistenz, Navigation, externen Dependencies oder Build-Regeln wird ein ADR angelegt:

```bash
cp docs/architecture/adr/template.md docs/architecture/adr/000X-kurzer-titel.md
```
