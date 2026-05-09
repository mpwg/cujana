# ADR-0011: Open-Meteo Wetterdaten für die Home-Prognose

Status: Akzeptiert
Datum: 2026-05-09

## Kontext

Die Cujana-Startseite zeigt nur noch eine kompakte Prognose für heute und morgen sowie den Check-in-CTA. Für diese Prognose werden neben Pollendaten auch Wetterdaten benötigt.

Open-Meteo stellt Wetter- und Pollendaten bereit. Die App muss die Datenquellen sichtbar attribuieren und darf keine rohen API-Namen oder technischen Fehlermeldungen in der Home-UI anzeigen.

## Entscheidung

Cujana ergänzt die bestehende Open-Meteo-Integration um Wetterdaten. Die Wetteranbindung bleibt in `Cujana/Infrastructure/Network/OpenMeteo` und wird über ein Domain-Repository-Protokoll an Use Cases und ViewModels angebunden.

Die Home-UI zeigt nur eine zusammengefasste Darstellung für heute und morgen. Mapping von Open-Meteo-Wettercodes, Temperatur und Pollenbelastung passiert außerhalb der SwiftUI-Views. Die sichtbare Attribution lautet:

„Wetter- und Pollendaten: Open-Meteo.com, CC BY 4.0. Zusammengefasst für Cujana.“

## Konsequenzen

Die Startseite bleibt fokussiert und nutzt dieselbe externe Datenquelle für Wetter und Pollen. Features bleiben von Open-Meteo-DTOs und SDK-Details entkoppelt.

Änderungen an der Xcode-Projektdatei sind notwendig, weil neue Wetter-Domain-, Infrastruktur- und Testdateien in das Projekt aufgenommen werden.

## Alternativen

Eine zusätzliche Wetterdatenquelle wurde verworfen, weil sie Attribution, Fehlerverhalten und Datenabgleich unnötig komplex machen würde.

Wetter-Mapping direkt in SwiftUI-Views wurde verworfen, weil Views deklarativ bleiben und keine Businesslogik tragen sollen.

## Enforcement

`make architecture-check`, SwiftLint und Unit-Tests sichern die Schichtgrenzen, die DTO-Mappings und das Home-ViewModel-Verhalten ab.

Projektdatei-Änderungen für die Open-Meteo-Wetterintegration sind durch diese ADR abgedeckt, solange keine weiteren externen Datenquellen oder neuen Schichtabhängigkeiten eingeführt werden.
