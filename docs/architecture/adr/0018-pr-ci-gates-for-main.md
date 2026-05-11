# ADR-0018: PR-CI-Gates für main

Status: Akzeptiert
Datum: 2026-05-11

## Kontext

Der `ios-ci`-Workflow definierte iPhone-Unit-Tests und UI-Smoke-Jobs, setzte
diese Jobs bei Pull Requests aber pauschal auf `false`. Damit liefen sie nur bei
Pushes auf `main` oder bei manuellen Starts. CodeQL lief außerdem nur für
`release/**` und nicht für Pull Requests nach `main`.

Dadurch konnten Änderungen an App-Code, Testtargets, Projektdateien oder
Startpfaden vor dem Merge nach `main` ohne iPhone-Simulatorabdeckung, ohne
UI-Smoke und ohne automatisierte Swift-Codeanalyse bleiben.

## Entscheidung

`ios-ci` berechnet bei Pull Requests die geänderten Dateien über die GitHub API.
iPhone-Unit-Tests laufen für Änderungen an App-Code, Unit-Tests, UI-Tests,
Projektdateien, relevanter Konfiguration, Testskripten, Fastlane-Dateien und dem
Workflow selbst.

Der UI-Smoke läuft für Änderungen an App-Startpfad, UI-Features, Designsystem,
Assets, Ressourcen, UI-Tests, Projektdateien, relevanter Konfiguration,
Snapshot-Konfiguration und dem Workflow selbst.

CodeQL läuft zusätzlich für Pull Requests nach `main`, wenn produktive Swift-,
Test-, Projekt-, Konfigurations- oder CodeQL-Workflow-Dateien betroffen sind.

## Konsequenzen

Pull Requests nach `main` erhalten vor dem Merge eine breitere iOS-Abdeckung.
Kleine Dokumentationsänderungen lösen weiterhin keine teuren Simulator- oder
CodeQL-Läufe aus.

Die Pfadlisten in `ios-ci.yml` und `codeql.yml` müssen mit neuen Schemes,
Testtargets, Startpfaden oder CI-relevanten Skripten mitgepflegt werden.
