# ADR-0005: OpenMeteo SDK für Pollendaten

Status: Akzeptiert
Datum: 2026-05-07

## Kontext

Cujana benötigt Pollenvorhersagen für Koordinaten. Die Open-Meteo Air Quality API stellt dafür tägliche Variablen wie `alder_pollen`, `birch_pollen`, `grass_pollen`, `mugwort_pollen` und `ragweed_pollen` bereit.

Für die Integration soll das offizielle Open-Meteo Swift-Package genutzt werden. Das Package `open-meteo/open-meteo` enthält den Open-Meteo-API-Server und ist nicht als iOS-Client-SDK geeignet. Das offizielle Client-SDK liegt unter `open-meteo/sdk` und liefert das Swift-Produkt `OpenMeteoSdk`.

## Entscheidung

Cujana bindet `https://github.com/open-meteo/sdk.git` als Swift Package ein und nutzt `OpenMeteoSdk` ausschließlich in `Cujana/Infrastructure/Network/OpenMeteo`.

Die Infrastruktur ruft die Open-Meteo Air Quality API mit `format=flatbuffers` ab und kapselt die SDK-Antwort in eigene DTOs. Domain und Features kennen weder `OpenMeteoSdk` noch die Open-Meteo-Parameter.

## Konsequenzen

Pollendaten können effizient über das offizielle FlatBuffers-SDK geladen werden. Die Domain bleibt unabhängig von Netzwerk, SDK und DTO-Details.

Die unterstützten MVP-Variablen sind auf die vom SDK abgebildeten Pollenarten begrenzt: Erle, Birke, Gras, Beifuß und Ragweed. Weitere Domain-Pollenarten bleiben möglich, werden aber erst gemappt, wenn Open-Meteo dafür API-Variablen bereitstellt oder eine weitere Datenquelle ergänzt wird.

## Alternativen

Eine direkte JSON-Integration mit `URLSession` wurde verworfen, weil sie das offizielle SDK ignorieren und zusätzliche Decoding-Logik in der App erzeugen würde.

Das Package `open-meteo/open-meteo` wurde verworfen, weil es der API-Server ist und nur macOS als Plattform deklariert. Für Cujana als iOS-App ist `open-meteo/sdk` das passende offizielle Client-Package.

## Enforcement

`OpenMeteoSdk` wird nur in `Infrastructure/Network/OpenMeteo` importiert. Feature-Code greift weiterhin nur auf Use Cases oder Repository-Protokolle zu. `make architecture-check`, SwiftLint und Unit-Tests sichern die Schichtgrenzen und Mapper-Logik ab.

Die Xcode-Projektdatei führt das `OpenMeteoSdk`-Produkt im App-Target. Projektdatei-Änderungen an dieser Einbindung bleiben von dieser ADR abgedeckt, solange sie keine zusätzlichen Produktabhängigkeiten oder neuen Schichtzugriffe einführen.

Der Architektur-Guardrail-Workflow begrenzt `xcodebuild test` auf `CujanaTests`. UI-Tests bleiben von dieser Dependency- und Architekturprüfung getrennt, weil sie auf GitHub-Hosted-Simulatoren anfälliger für Accessibility-Initialisierungs-Timeouts sind.
