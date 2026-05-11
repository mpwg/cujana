# ADR-0020: SwiftData Persistence Boundary

Status: Akzeptiert
Datum: 2026-05-11

## Kontext

Das Xcode-Template-Modell `Item.swift` lag im App-Root und wurde durch die synchronisierte Xcode-Gruppe automatisch Teil des App-Targets. Die bisherigen Architekturprüfungen verboten SwiftData in `Domain` und `Features`, ließen aber SwiftData-Modelle und direkte `ModelContext`-Nutzung an anderen App-Pfaden zu.

Damit konnte toter Template-Code im Produkt-Build bleiben, und neue Persistenzmodelle konnten außerhalb des expliziten Persistenzbereichs entstehen.

## Entscheidung

SwiftData bleibt im App-Code auf `Cujana/Infrastructure/Persistence` beschränkt. Das gilt für `import SwiftData`, `@Model`, `ModelContainer` und `ModelContext`.

Lokale Repository-Implementierungen, die direkt mit SwiftData arbeiten, gehören ebenfalls in diesen Persistence-Bereich. Tests dürfen SwiftData weiterhin verwenden, um Persistenzverhalten und Migrationen direkt zu prüfen.

## Konsequenzen

SwiftData-Schema, Container-Erzeugung und direkte Kontextzugriffe liegen an einem klar prüfbaren Ort. Neue App-Dateien außerhalb von `Infrastructure/Persistence` können keine SwiftData-Oberfläche einführen, ohne dass lokale Checks oder CI fehlschlagen.

Repository-Dateipfade bilden nun stärker die technische Persistenzgrenze ab als die fachliche Repository-Kategorie.

## Alternativen

Eine breite Ausnahme für `Cujana/Infrastructure/Repositories` wurde verworfen, weil sie die Grenze zu unscharf macht und dort neue SwiftData-Typen ohne gezielte Persistenzentscheidung erlauben würde.

## Enforcement

`scripts/check_architecture.sh` meldet SwiftData-API-Nutzung außerhalb von `Cujana/Infrastructure/Persistence` und Tests als Fehler. Eine SwiftLint-Custom-Rule spiegelt die Regel lokal für App-Code.
