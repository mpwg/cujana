# ADR-0007: CI-Jobs laufen getrennt und bevorzugt auf Ubuntu

Status: Akzeptiert  
Datum: 2026-05-07

## Kontext

Der Architektur-Workflow führte Architekturcheck, SwiftLint und Xcode-Tests in einem einzigen `macos-26`-Job aus. Dadurch warteten schnelle, plattformunabhängige Checks auf einen macOS-Runner und blockierten sich gegenseitig.

Das Projekt benötigt macOS weiterhin für `xcodebuild test`, weil der iOS-Simulator und Xcode 26.4.1 erforderlich sind. Architekturregeln und SwiftLint benötigen dagegen keinen Simulator.

## Entscheidung

Der Workflow wird in drei unabhängige Jobs aufgeteilt:

- Architekturcheck auf `ubuntu-latest`
- SwiftLint auf `ubuntu-latest` mit dem SwiftLint-Container `ghcr.io/realm/swiftlint:0.63.2`
- Xcode-Tests auf `macos-26`

Außerdem bricht GitHub Actions ältere Läufe derselben Branch per `concurrency.cancel-in-progress` ab. Der Xcode-Job nutzt das bekannte Projekt und Scheme direkt, statt sie zur Laufzeit zu suchen.

Für den CI-Unit-Test gibt es ein shared Scheme `Cujana-UnitTests`, das nur App und Unit-Test-Bundle baut. UI-Tests bleiben als eigenes Target erhalten, werden aber nicht mehr im Guardrail-Workflow mitgebaut.

SwiftLint wird aus dem Xcode-Build entfernt und nur noch im CI-Workflow sowie über explizite lokale Befehle wie `make lint` ausgeführt.

Der Xcode-Job verwendet einen festen DerivedData-Pfad. GitHub Actions cached Xcodes `SourcePackages`, Build-Produkte, Modul-Caches und SDK-Stat-Caches. Paketversionen kommen ausschließlich aus `Package.resolved`, und Xcode-Tests laufen mit parallelen Test-Workern sowie deaktiviertem Index Store.

Der Simulator-Start läuft im Hintergrund parallel zur Paketauflösung und zum direkten `xcodebuild test`. Dadurch kann Xcode Build und Testplanung selbst optimieren, während Simulator-Startzeit mit Resolve und Kompilierung überlappt. Der Boot-Prozess wird am Ende des Schritts aufgeräumt, damit er den Job nicht blockiert.

## Konsequenzen

Architekturcheck und SwiftLint können parallel zum macOS-Test starten und belegen keinen knapperen macOS-Runner. Neue Commits auf derselben Branch verschwenden keine Runner-Zeit für überholte Läufe.

SwiftLint ist durch den Container an Version 0.63.2 gebunden. Updates erfolgen bewusst über eine Workflow-Änderung.

Xcode-Caches können bei Build-System-Änderungen stale werden. Die Cache-Keys enthalten deshalb Xcode-Version, `Package.resolved`, Projektdatei, shared Schemes und Swift-Quellen; ältere Caches werden nur als Restore-Fallback genutzt und von Xcode inkrementell validiert.

Lokale Cache-Verzeichnisse sind in `.gitignore` eingetragen und werden vom Architekturcheck ausgeschlossen.

## Alternativen

Alle Checks in einem macOS-Job zu belassen wurde verworfen, weil dadurch schnelle Checks unnötig auf macOS warten.

SwiftLint per Homebrew auf macOS zu installieren wurde verworfen, weil Installation und macOS-Runner-Wartezeit langsamer sind als ein Linux-Container.

## Enforcement

GitHub Actions führt Architekturcheck und SwiftLint auf Ubuntu aus. Nur der Simulator-Test mit `Cujana-UnitTests` bleibt auf `macos-26`.
