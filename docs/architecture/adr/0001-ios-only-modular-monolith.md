# ADR-0001: iOS-fokussierter SwiftUI-first modularer Monolith

Status: Akzeptiert  
Datum: 2026-05-04

## Kontext

Cujana startet als neue App. Die App ist explizit auf die **iOS-Plattformfamilie** fokussiert: iPhone und iPad sind primär, Mac Catalyst ist als Build- und Ausführungsziel eingeschlossen. Das System muss wartbar und einfach verständlich bleiben.

Zu frühe Cross-Platform-Abstraktionen oder zu viele technische Module würden den Start verlangsamen und die Architektur schwerer verständlich machen.

## Entscheidung

Cujana wird als **SwiftUI-first iOS-App** mit **modular-monolithischer Struktur** gebaut. Mac Catalyst ist Teil dieser iOS-Produktmatrix; native macOS- und visionOS-Targets sind nicht vorgesehen.

Konkret:

- Swift und SwiftUI sind die Standardtechnologie für UI.
- UIKit ist nur als Adapter oder für spezielle iOS-Brücken erlaubt.
- Es gibt keine Android-, Web-, visionOS-, native-macOS- oder Cross-Platform-Schicht.
- Feature-Code wird in `Cujana/Features/<FeatureName>` organisiert.
- Fachlogik liegt in `Cujana/Domain`.
- Technische Implementierungen liegen in `Cujana/Infrastructure` oder `Cujana/Platform`.
- Physische Swift Packages werden erst eingeführt, wenn die Ordnergrenzen nicht mehr ausreichen.

## Konsequenzen

Vorteile:

- Sehr einfacher Start.
- Gute Lesbarkeit der Ordnerstruktur.
- Nativer Zugriff auf iOS-/iPadOS-Funktionen und schnelle Mac-Catalyst-Builds.
- Weniger Framework-Komplexität.
- Gute Testbarkeit durch getrennte Domain und Infrastructure.

Nachteile:

- Keine Wiederverwendung für Android oder Web.
- Architekturgrenzen müssen aktiv enforced werden, weil anfangs nicht jedes Layer ein eigenes Modul ist.
- Spätere Modularisierung kann Migration erfordern, wenn die App stark wächst.

## Alternativen

### Viele Swift Packages ab Tag 1

Verworfen, weil zusätzliche Build- und API-Komplexität entsteht, bevor der tatsächliche Bedarf klar ist.

### Cross-Platform Framework

Verworfen, weil Cujana auf die iOS-Plattformfamilie fokussiert ist und native Wartbarkeit Vorrang hat.

### Massive MVC / alles im App Target ohne Regeln

Verworfen, weil fehlende Grenzen schnell zu schwer wartbaren Views, Services und Singletons führen.

## Enforcement

- `scripts/check_architecture.sh` prüft verbotene Imports und direkte Infrastrukturzugriffe.
- `.swiftlint.yml` ergänzt Regex-basierte Regeln.
- `.github/workflows/architecture-guardrails.yml` führt Checks in CI aus.
- Architekturänderungen brauchen ein weiteres ADR.
