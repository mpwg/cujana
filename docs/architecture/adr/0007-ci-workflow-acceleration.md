# ADR-0007: CI-Jobs laufen getrennt und bevorzugt auf Ubuntu

Status: Akzeptiert  
Datum: 2026-05-07

## Kontext

Der Architektur-Workflow führte Architekturcheck, SwiftLint und Xcode-Tests in einem einzigen `macos-26`-Job aus. Dadurch warteten schnelle, plattformunabhängige Checks auf einen macOS-Runner und blockierten sich gegenseitig.

Das Projekt benötigt macOS weiterhin für `xcodebuild test`, weil Xcode erforderlich ist. Architekturregeln und SwiftLint benötigen dagegen weder Xcode noch macOS.

## Entscheidung

Der Workflow wird in drei unabhängige Jobs aufgeteilt:

- Architekturcheck auf `ubuntu-latest`
- SwiftLint auf `ubuntu-latest` mit dem SwiftLint-Container `ghcr.io/realm/swiftlint:0.63.2`
- Xcode-Tests auf `macos-26` mit Mac Catalyst

Außerdem bricht GitHub Actions ältere Läufe derselben Branch per `concurrency.cancel-in-progress` ab. Der Xcode-Job nutzt das bekannte Projekt und Scheme direkt, statt sie zur Laufzeit zu suchen.

Für den CI-Unit-Test gibt es ein shared Scheme `Cujana-UnitTests`, das nur App und Unit-Test-Bundle baut. UI-Tests bleiben als eigenes Target erhalten, werden aber nicht mehr im Guardrail-Workflow mitgebaut.

SwiftLint wird aus dem Xcode-Build entfernt und nur noch im CI-Workflow sowie über explizite lokale Befehle wie `make lint` ausgeführt.

Der Xcode-Job verwendet einen festen DerivedData-Pfad, Xcode 26.4, eine arm64-Mac-Catalyst-Destination und Deployment Target 26.0. GitHub Actions cached Xcodes `SourcePackages`, Build-Produkte, Modul-Caches und SDK-Stat-Caches; die Xcode-Version wird zur Laufzeit für den Cache-Key ermittelt. Paketversionen kommen ausschließlich aus `Package.resolved`, und Xcode-Tests laufen als Mac-Catalyst-Tests mit parallelen Test-Workern sowie deaktiviertem Index Store.

Der CI-Step übernimmt Symis Xcode-Auswahl und Cache-Setup. Für Cujana wird generisch für Mac Catalyst mit `build-for-testing` gebaut und die erzeugte `.xctestrun` danach mit `test-without-building` gegen `My Mac` ausgeführt, weil der GitHub-Arm-Runner keine konkrete arm64-Catalyst-Destination für dieses Scheme anbietet.

`CujanaTests` unterstützt Mac Catalyst explizit, damit App und Testbundle in denselben Catalyst-Build-Produkten landen. Der CI-Job setzt das Catalyst-Deployment-Target passend zum Runner-SDK. Dadurch entfällt der Simulator-Start vollständig.

## Konsequenzen

Architekturcheck und SwiftLint können parallel zum macOS-Test starten und belegen keinen knapperen macOS-Runner. Neue Commits auf derselben Branch verschwenden keine Runner-Zeit für überholte Läufe.

SwiftLint ist durch den Container an Version 0.63.2 gebunden. Updates erfolgen bewusst über eine Workflow-Änderung.

Xcode-Caches können bei Build-System-Änderungen stale werden. Die Cache-Keys enthalten deshalb Xcode-Version, `Package.resolved`, Projektdatei, shared Schemes und Swift-Quellen; ältere Caches werden nur als Restore-Fallback genutzt und von Xcode inkrementell validiert.

Lokale Cache-Verzeichnisse sind in `.gitignore` eingetragen und werden vom Architekturcheck ausgeschlossen.

## Alternativen

Alle Checks in einem macOS-Job zu belassen wurde verworfen, weil dadurch schnelle Checks unnötig auf macOS warten.

SwiftLint per Homebrew auf macOS zu installieren wurde verworfen, weil Installation und macOS-Runner-Wartezeit langsamer sind als ein Linux-Container.

## Enforcement

GitHub Actions führt Architekturcheck und SwiftLint auf Ubuntu aus. Nur der Xcode-Test mit `Cujana-UnitTests` bleibt auf `macos-26` und läuft dort ohne Simulator als Mac-Catalyst-Test.
