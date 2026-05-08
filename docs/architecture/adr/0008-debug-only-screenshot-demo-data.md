# ADR-0008: Screenshot-Demo-Daten nur im Debug-Build

Status: Akzeptiert

Datum: 2026-05-08

## Kontext

Fastlane-Screenshots und Xcode-Previews benötigen stabile, plausibel klingende Demo-Daten. Die produktive App darf dafür aber weder Standortberechtigungen abfragen noch Netzwerk- oder Persistenzdaten verwenden, weil Screenshots reproduzierbar sein müssen.

Gleichzeitig dürfen diese Demo-Daten nicht im Release-Build enthalten sein. Beispielhafte Symptome, Notizen, feste Koordinaten und Screenshot-Routing sind Hilfsmittel für Entwicklung und Store-Screenshots, nicht Teil der auslieferbaren App.

## Entscheidung

Die App erhält einen Screenshot-Modus, der nur unter `DEBUG` kompiliert wird. In diesem Modus wählt `AppLaunchConfiguration` anhand der Fastlane-Argumente den gewünschten Screenshot-Screen aus und `AppCompositionRoot.demo()` verdrahtet Demo-Repositories, feste Demo-Daten und eine feste Koordinate.

Xcode-Previews verwenden dieselbe Demo-Komposition wie Fastlane. Dadurch zeigen Previews und Screenshots dieselben Daten und denselben Screen-Zustand.

Release-Builds verwenden ausschließlich `AppCompositionRoot.production()`. Demo-Daten, Demo-Repositories, Screenshot-Screens, Screenshot-Routing und demo-basierte Preview-Pfade sind mit `#if DEBUG` ausgeschlossen. Diese Debug-Abschnitte liegen gebündelt in dedizierten Support-Dateien, damit produktiver App-Code keine verteilten Demo-Abzweigungen enthält.

## Konsequenzen

Screenshots fragen nicht nach dem Standort und hängen nicht von echten Pollen-, Standort- oder Symptomdaten ab.

Previews bleiben aussagekräftig, weil sie dieselbe Demo-Komposition nutzen wie Fastlane.

Neue Screenshot-Screens müssen im Debug-only-Screenshot-Routing ergänzt werden. Wenn sie Demo-Daten brauchen, müssen diese ebenfalls unter `#if DEBUG` bleiben.

Release-Builds können die Demo-Daten nicht referenzieren, weil die relevanten Typen und Codepfade dort nicht kompiliert werden.

## Alternativen

Demo-Daten über Laufzeit-Flags auch im Release-Build zu behalten wurde verworfen, weil die Daten und Routing-Pfade dann weiterhin im ausgelieferten Binary enthalten wären.

Separate Preview-Daten pro View wurden verworfen, weil Previews und Fastlane-Screenshots dadurch auseinanderlaufen würden.

Standortberechtigungen im Screenshot-Setup vorab zu setzen wurde verworfen, weil Screenshots dann weiter von produktiver Standortlogik abhängen würden.

## Enforcement

Der Screenshot-Modus und alle Demo-Daten sind mit `#if DEBUG` geschützt. Neue Debug-only-Pfade werden in den bestehenden Debug-/Preview-Support-Dateien ergänzt, nicht verteilt in produktiven Views oder Feature-Komposition.

Lokale Verifikation umfasst:

- Debug-Screenshot-Build mit `CujanaScreenshots`
- Release-Build des Schemes `Cujana`
- String-Scan des Release-Binaries auf Demo- und Screenshot-Bezeichner
- Fastlane-Screenshot-Lauf mit `bundle exec fastlane ios sync_screenshots pages:all`
