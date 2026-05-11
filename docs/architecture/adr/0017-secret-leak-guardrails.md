# ADR-0017: Secret-Leak-Guardrails für Build Settings

Status: Akzeptiert
Datum: 2026-05-11

## Kontext

`Configuration/LocalSecrets.xcconfig` wird lokal und in CI erzeugt, darf aber
keine echten Werte im Repository enthalten. Ein Force-Add oder kopierte
Build-Settings könnten App-Store-, Telemetrie-, Sentry- oder Datenquellenwerte in
Commits, Pull Requests, Issues oder Logs sichtbar machen.

## Entscheidung

Ein dedizierter Check `scripts/check_secret_leaks.sh` scannt versionierte Dateien
auf committete `LocalSecrets.xcconfig`-Werte, literal gesetzte Secret-Build-
Settings und Shell-Xtrace in Build-, Release- und CI-Skripten. Der Check läuft
lokal über `make secret-check` und als Teil von `make architecture-check`.

Die Architektur-Guardrail in CI führt denselben Check für Pull Requests und
Pushes auf `main` aus.

## Konsequenzen

Ein versehentlich force-addetes `Configuration/LocalSecrets.xcconfig` mit
nicht-leeren Secret-Werten bricht lokal und in CI ab. Skripte müssen Secret-
Werte über Environment- oder CI-Secret-Referenzen beziehen und dürfen keine
Shell-Xtrace-Ausgaben aktivieren.

Die Prüfung ist bewusst textbasiert und eng auf bekannte Cujana-Build-Settings
begrenzt. Allgemeines Secret Scanning bei GitHub bleibt zusätzlich sinnvoll,
ersetzt aber diese repository-spezifische Guardrail nicht.

## Alternativen

Nur `.gitignore` wurde verworfen, weil Force-Adds ignorierte Dateien trotzdem
versionieren können.

Nur GitHub Secret Scanning wurde verworfen, weil die repository-spezifischen
`LocalSecrets.xcconfig`-Muster lokal vor dem Push erkannt werden sollen.

## Enforcement

`make architecture-check` führt `scripts/check_secret_leaks.sh` aus. Die GitHub
Actions Workflow `Architecture Guardrails` führt denselben Check aus, damit ein
Pull Request mit committeten nicht-leeren Secret-Werten fehlschlägt.
