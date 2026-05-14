# ADR-0026: Persistenten Background-Standort entfernen

Status: Akzeptiert
Datum: 2026-05-14

## Kontext

App Review hat Version 1.0.0 abgelehnt, weil Cujana `location` in
`UIBackgroundModes` deklariert und eine Always-Location-UI anbietet, aber keine
Funktion besitzt, die persistente Echtzeit-Standortaktualisierungen benötigt.

Cujana benötigt Standortdaten nur optional und grob gerastert, um Wetter- und
Pollendaten für die Umgebung zu laden. Die App ist keine Tracking-App und kann
die wichtigsten Daten beim Öffnen bzw. bei Nutzerinteraktion aktualisieren.

## Entscheidung

Cujana fordert nur noch Standortzugriff beim Verwenden der App an.
`NSLocationAlwaysAndWhenInUseUsageDescription` und der `location`-Eintrag in
`UIBackgroundModes` werden entfernt. Der Settings-Screen bietet keinen
„Immer-Standort erlauben“-Pfad mehr an.

`fetch` bleibt als einziger Background Mode erhalten, damit iOS kurze
opportunistische Refresh-Fenster vergeben kann. Dieser Pfad darf nicht als
zuverlässiger Scheduler oder als Ersatz für Foreground-Refresh behandelt werden.

## Konsequenzen

Die App-Store-Review-Notes müssen explizit erklären, dass Cujana keinen
persistenten Standort im Hintergrund nutzt. WeatherKit wird als Wetterquelle
benannt, inklusive Navigationshinweis für den Review.

Bestehende Architektur- und Testnamen, die „Always“ als fachliche Anforderung
beschreiben, werden auf allgemeine Standortautorisierung umgestellt. Legacy-
Status `.authorizedAlways` wird weiterhin toleriert, aber nicht mehr aktiv
angefordert.

## Alternativen

Den `location`-Background-Mode zu behalten wurde verworfen, weil Cujana keine
persistenten Echtzeit-Standortfeatures anbietet.

Region Monitoring oder Significant-Change Location Services wurden verworfen,
weil der MVP keine standortgetriebenen Benachrichtigungen oder kontinuierlichen
Umgebungswechsel auswertet.
