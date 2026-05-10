# ADR-0013: Lokale Secrets als Build-Konfiguration

Status: Akzeptiert  
Datum: 2026-05-10

## Kontext

Die Polleninformation-Integration benötigt einen API-Key, der nicht zur Laufzeit aus
Environment-Variablen gelesen werden darf. Xcode-Builds sollen stattdessen immer die
Werte aus `Configuration/LocalSecrets.xcconfig` verwenden.

## Entscheidung

Das Xcode-Projekt bindet `Configuration/LocalSecrets.xcconfig` als Base Configuration
für Debug- und Release-Builds ein. Secrets werden damit als Build Settings aufgelöst
und können in generierte App-Konfiguration übernommen werden.

## Konsequenzen

Der API-Key bleibt eine Build-Time-Konfiguration und wird nicht dynamisch aus der
Prozessumgebung gelesen. Lokale und CI-Builds müssen sicherstellen, dass die benötigten
Werte vor dem Build in `Configuration/LocalSecrets.xcconfig` stehen.

Änderungen an dieser Build-Konfiguration bleiben architekturkritisch, weil sie den
Umgang mit Secrets und Datenquellen beeinflussen.

## Alternativen

Runtime-Environment-Variablen wurden verworfen, weil die App den API-Key nur zur
Build-Zeit übernehmen soll.

Eine fest eingecheckte Secret-Datei wurde verworfen, weil echte Secrets nicht ins
Repository gehören.

## Enforcement

`make architecture-check` verlangt für Änderungen am Xcode-Projekt und an Build- oder
CI-Regeln eine ADR. Tests prüfen zusätzlich, dass unaufgelöste Build-Setting-Platzhalter
nicht als gültiger Polleninformation-API-Key verwendet werden.
