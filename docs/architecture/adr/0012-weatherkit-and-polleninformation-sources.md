# ADR-0012: WeatherKit und Polleninformation als externe Datenquellen

Status: Akzeptiert
Datum: 2026-05-09

## Kontext

Cujana benötigt Wetterdaten für die Home-Prognose und Pollendaten inklusive zusätzlicher Allergierisiko-Informationen. Die bisherige Open-Meteo-Integration soll vollständig ersetzt werden.

Der Polleninformationsdienst verlangt Fair-Use-Verhalten und Attribution:

„Österreichischer Polleninformationsdienst, www.polleninformation.at“

API-Schlüssel dürfen nicht zur Laufzeit aus Environment Variables gelesen werden. Lokale Secrets kommen aus `Configuration/LocalSecrets.xcconfig` und werden zur Build-Zeit in die App-Konfiguration übernommen.

## Entscheidung

Wetterdaten werden über WeatherKit geladen. Pollendaten und Allergierisiken werden über das installierte `polleninformation` Swift Package geladen.

Die Open-Meteo-Infrastruktur wird entfernt. WeatherKit- und Polleninformation-DTOs bleiben in `Infrastructure`. Feature-Code spricht weiterhin nur mit Domain-Use-Cases und Repository-Protokollen.

Polleninformation-Antworten werden für vier Stunden gecacht. Wenn die API für einen Standort keine interpretierbaren Pollendaten liefert, zeigt die App keine technische Fehlermeldung, sondern behandelt den Fall als leere Pollendaten für diesen Standort.

Tracing und Logging laufen über die App-Observability-Schicht. Debug-Builds schreiben in die lokale Debug-Ausgabe. Sentry erhält Logs und Traces nur nach Opt-in.

## Konsequenzen

Die App erfüllt die Fair-Use-Anforderung des Polleninformationsdienstes und zeigt die verpflichtende Datenherkunft in der Prognoseansicht.

Die Xcode-Projektdatei ändert sich, weil Open-Meteo-Dateien entfernt und WeatherKit-, Polleninformation- und Observability-Dateien aufgenommen werden.

Builds benötigen `POLLENINFORMATION_API_KEY` in `Configuration/LocalSecrets.xcconfig`. Ein nicht expandierter Build-Setting-Platzhalter wird als fehlender API-Key behandelt.

## Alternativen

Open-Meteo beizubehalten wurde verworfen, weil Wetterdaten vollständig über WeatherKit kommen sollen.

Runtime-Environment-Variablen wurden verworfen, weil Secrets ausschließlich zur Build-Zeit aus der lokalen xcconfig übernommen werden sollen.

## Enforcement

`make architecture-check`, `swiftlint lint --strict` und Unit-Tests sichern die Schichtgrenzen, Lint-Regeln und das Fehlerverhalten der neuen Datenquellen ab.
