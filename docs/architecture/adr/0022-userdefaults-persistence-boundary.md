# ADR 0022: UserDefaults-Persistenzgrenze

## Status

Accepted

## Kontext

Kleine App-Einstellungen gehören laut Architekturleitlinien hinter gekapselte Stores in
`Cujana/Infrastructure/Persistence`. Direkte Zugriffe über `UserDefaults.standard` außerhalb dieser
Grenze machen Persistenzentscheidungen in App- und Feature-Schichten sichtbar.

## Entscheidung

Direkte `UserDefaults.standard`-Nutzung ist nur in `Cujana/Infrastructure/Persistence` und in Tests
erlaubt. App- und Feature-Code hängt von Protokollen ab und erhält konkrete Stores aus der
Komposition oder über Default-Injektion.

Die Architekturprüfung und SwiftLint erzwingen diese Grenze für neuen Code.

## Konsequenzen

Neue kleine Einstellungen bekommen einen Store in `Infrastructure/Persistence`.
Tests für App-Services sollen In-Memory-Fakes injizieren, wenn keine Persistenz selbst geprüft wird.
