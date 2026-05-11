# ADR-0018: Background-Refresh mit Always-Location-Gate

Status: Akzeptiert
Datum: 2026-05-11

## Kontext

Cujana aktualisiert Umwelt-, Wetter- und Pollendaten opportunistisch über einen
`BGAppRefreshTask`. Der Task ist für kurze Inhaltsaktualisierungen gedacht und
wird vom System geplant; die App darf weder einen exakten Ausführungszeitpunkt
noch eine garantierte Ausführung annehmen.

Für die Aktualisierung benötigt Cujana einen Standort. Ein Standortabruf aus
einem Background-Task darf nicht nur auf When-In-Use-Berechtigung beruhen,
sondern muss die Always-Berechtigung anfordern und voraussetzen. Apple beschreibt
`requestAlwaysAuthorization()` als den separaten Weg, um nach When-In-Use auf
Always zu erweitern.

Der aktuelle App-Pfad registriert den Task beim App-Start in `CujanaApp`, plant
ihn über `EnvironmentalDataRefreshCoordinator` und erlaubt die Task-ID über
`BGTaskSchedulerPermittedIdentifiers` in `Info.plist`. `UIBackgroundModes`
enthält `fetch` und `location`; die Location-Nutzung ist über
`NSLocationWhenInUseUsageDescription` und
`NSLocationAlwaysAndWhenInUseUsageDescription` begründet.

Referenzen:

- [Apple: BGAppRefreshTask](https://developer.apple.com/documentation/backgroundtasks/bgapprefreshtask)
- [Apple: requestAlwaysAuthorization()](https://developer.apple.com/documentation/corelocation/cllocationmanager/requestalwaysauthorization%28%29)
- [Apple: Requesting authorization to use location services](https://developer.apple.com/documentation/corelocation/requesting-authorization-to-use-location-services)

## Entscheidung

Der Background-Refresh bleibt ein `BGAppRefreshTask` für kurze opportunistische
Aktualisierungen. Der Task wird nach jedem Handle erneut geplant, damit das
System künftige Refresh-Fenster vergeben kann.

Vor einem Standortabruf im Background-Task ruft der Coordinator
`requestBackgroundLocationRefreshAuthorization()` auf. Nur wenn dieser Aufruf
Always-Location bestätigt, wird `currentCoordinate()` ausgeführt und der
`RefreshEnvironmentalDataUseCase` gestartet. Ein reiner Check auf den aktuellen
Status reicht nicht aus, weil ein vorhandenes When-In-Use nicht für den
Background-Refresh-Pfad genügt.

Der CoreLocation-Provider behandelt die Always-Anforderung sequenziell:

- Bei `.notDetermined` wird zuerst When-In-Use und danach Always angefordert.
- Bei `.authorizedWhenInUse` wird Always separat angefordert.
- Bei `.authorizedAlways` wird der Background-Refresh direkt freigegeben.
- Bei Ablehnung oder Cancellation wird der Background-Refresh abgebrochen.

## Konsequenzen

Background-Refresh und Foreground-Refresh haben unterschiedliche Gates:
Foreground-Aufrufe dürfen mit When-In-Use arbeiten, Background-Tasks müssen
Always-Location durchlaufen. Dadurch bleibt der normale App-Start weniger
invasiv, während der Background-Pfad keine Standortabfrage mit unzureichender
Berechtigung versucht.

Die App darf den Background-Refresh nicht als zuverlässigen Scheduler für
kritische Produktlogik behandeln. Daten müssen weiterhin beim App-Start bzw. bei
Nutzerinteraktion aktualisierbar bleiben.

Cancellation aus dem `BGAppRefreshTask.expirationHandler` muss wartende
Authorization- und Location-Continuations deterministisch beenden, damit der
Task sauber als fehlgeschlagen abgeschlossen werden kann.

## Alternativen

Nur `allowsBackgroundLocationRefresh` vor dem Standortabruf zu prüfen wurde
verworfen. Das verhindert zwar unberechtigte Refreshes, fordert Always aber im
Task-Pfad nicht aktiv an.

Ein `BGProcessingTask` wurde verworfen, weil Cujanas Ablauf ein kurzer
Netzwerk-/Persistenz-Refresh ist und keine längere Verarbeitung mit
Processing-Semantik benötigt.

Kontinuierliche Background-Location-Updates wurden verworfen, weil Cujana keine
Tracking-App ist und nur gelegentlich grob gerasterte Umweltkontexte laden soll.

## Enforcement

`EnvironmentalDataRefreshCoordinatorTests` prüft, dass der Background-Task-Pfad
vor `currentCoordinate()` Always-Authorization anfordert und bei Ablehnung keinen
Standort lädt.

`CoreLocationCoordinateProviderTests` prüft parallele Authorization- und
Location-Anfragen sowie Cancellation, damit keine Continuations hängen bleiben.

SwiftLint und die Unit-Tests sind Pflichtchecks für Änderungen an diesem Pfad.
