# MVP Architektur- und Qualitäts-Gate

Status: **abgeschlossen für MVP**

Dieses Gate fasst die Abschlussprüfung für den MVP-Flow zusammen. Es ergänzt die bestehenden Architekturregeln und ersetzt keine ADR.

## Geprüfter Flow

- App-Einstieg lädt `AllergyDashboardView` über die zentrale Composition.
- Pollendaten werden über `LoadAllergyOverviewUseCase` und das injizierte Pollen-Repository geladen.
- Symptome werden über `SymptomEntryViewModel` erfasst und über `SaveAllergySymptomEntryUseCase` gespeichert.
- Gespeicherte Symptome werden vom Dashboard über dasselbe Repository wieder geladen und angezeigt.
- Fehlerzustände sind Bestandteil des ViewState und zeigen nutzerfreundliche Texte statt technischer Fehlermeldungen.

## Lokale Nachweise

Folgende Checks sind für dieses Gate relevant:

```bash
make architecture-check
swiftlint lint --strict
make test
xcodebuild test \
  -project Cujana.xcodeproj \
  -scheme CujanaScreenshots \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -testLanguage de \
  -testRegion DE \
  -only-testing:CujanaUITests/CujanaUITests/testDashboardSymptomEntryAppearsInJournal
```

`make test` führt die Unit-Tests über das shared Scheme `Cujana-UnitTests` als Mac-Catalyst-Testlauf aus. Das entspricht dem Xcode-Testpfad des CI-Guardrail-Workflows und verhindert, dass ein lokaler Testlauf ohne ausgeführte Tests grün wird.
Der zentrale UI-Smoke läuft separat über das shared Scheme `CujanaScreenshots` auf dem iPhone-Simulator und wird in CI für relevante iOS-PRs ausgeführt.

## Architekturprüfung

- Keine neuen produktiven Dependencies.
- Keine neue Architekturabweichung.
- Kein ADR nötig, weil keine Schichtenentscheidung, Dependency oder Ausnahme eingeführt wurde.
- Keine globalen App-Singletons.
- Keine generischen `Manager`-Klassen.
- Feature-Code greift weiterhin nicht direkt auf Netzwerk oder Persistenz zu.
- Infrastruktur bleibt hinter Domain-Protokollen.

## Bekannte Einschränkungen

- Der MVP verwendet weiterhin Wien als feste Startkoordinate.
- UI-Tests bleiben außerhalb des schnellen Unit-Guardrail-Testpfads und sind nicht Teil von `make test`.
- Die Fehlerzustände sind bewusst nutzerfreundlich, aber noch nicht nach Ursache differenziert.

## Follow-up-Issues

Nach dem MVP sollten diese Themen separat verfolgt werden:

- #29: Standortauswahl oder Standortfreigabe statt fester Wien-Koordinate.
- #28: Dedizierter UI-Testpfad für den wichtigsten Dashboard- und Symptomerfassungsflow.
- #27: Feiner abgestufte Fehlertexte für Netzwerk-, Daten- und Speicherprobleme.
