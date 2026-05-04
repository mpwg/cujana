# ADR-0003: CI nutzt macOS 26 und iOS 26.4

Status: Akzeptiert  
Datum: 2026-05-04

## Kontext

Cujana verwendet ein iOS Deployment Target von 26.4. Der bisherige GitHub-Actions-Runner `macos-latest` stellte im CI-Lauf Xcode 16.4 bereit und der Workflow wählte den nicht installierten Simulator `iPhone 16`.

Dadurch konnten Architekturcheck und SwiftLint erfolgreich laufen, der Xcode-Testschritt brach aber ab, bevor Tests gestartet wurden.

## Entscheidung

Der Architektur-Workflow läuft auf `macos-26`, wählt explizit Xcode 26.4.1 und nutzt den auf diesem Runner installierten Simulator `iPhone 17`.

## Konsequenzen

Die CI-Umgebung passt zum Deployment Target des Projekts und verwendet eine konkrete, dokumentierte Xcode- und Simulator-Kombination.

Der Workflow ist dadurch enger an das GitHub-Runner-Image gebunden. Wenn GitHub die installierten Simulatoren ändert, muss diese Entscheidung geprüft und der Workflow angepasst werden.

## Alternativen

`macos-latest` beizubehalten wurde verworfen, weil diese Bezeichnung aktuell auf einen Runner mit unpassender Xcode-Version zeigt.

Eine generische Destination wie `Any iOS Simulator Device` wurde verworfen, weil sie weniger deterministisch ist und Fehler durch unpassende Runtimes schwerer nachvollziehbar macht.

## Enforcement

GitHub Actions führt den Xcode-Testschritt mit der festgelegten Runner-, Xcode- und Simulator-Kombination aus.
