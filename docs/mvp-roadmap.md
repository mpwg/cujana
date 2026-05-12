# Weg zum MVP: Allergie, Pollendaten und Symptomerfassung

Status: **Historischer MVP-Plan, durch ADR-0012 bei Datenquellen aktualisiert**  
Ziel: **GitHub EPIC + Sub-Issues als umsetzbarer MVP-Plan**  
Scope: **iOS-only App, Allergie-MVP**

> Hinweis: Dieser Plan enthält noch historische OpenMeteo-Aufgaben. Für neue Umsetzung gilt [ADR-0012](architecture/adr/0012-weatherkit-and-polleninformation-sources.md): Wetterdaten kommen aus WeatherKit, Pollendaten und Allergierisiken aus Polleninformation.

## 1. Ziel

Der MVP von Cujana soll Nutzer:innen ermöglichen, aktuelle Pollendaten zu sehen, Allergie-Symptome einzugeben und diese Informationen verständlich in der App angezeigt zu bekommen.

Der erste Scope bleibt bewusst klein:

- Pollendaten über Polleninformation abrufen.
- Wetterdaten über WeatherKit abrufen.
- Symptome eingeben.
- Aktuell nur Allergie-Symptome unterstützen.
- Pollendaten und Symptomdaten anzeigen.

Das System muss trotzdem so gebaut werden, dass später weitere Informationen ergänzt werden können, zum Beispiel weitere Umweltinformationen, weitere Gesundheitskontexte oder zusätzliche Datenquellen.

## 2. Architektur-Leitplanken

Dieser MVP folgt den bestehenden Architekturregeln aus [`docs/architecture/README.md`](../architecture/README.md), [`docs/architecture/enforcement.md`](../architecture/enforcement.md) und [`.cujana/architecture.yml`](../../.cujana/architecture.yml).

Wichtige Leitplanken:

- Cujana bleibt eine SwiftUI-first iOS-only App.
- Der Code wächst als modularer Monolith mit klaren Feature-Slices.
- Business-Logik liegt in `Cujana/Domain` und ist unabhängig von SwiftUI, UIKit, Netzwerk und Persistenz.
- Repository-Protokolle liegen in `Domain`.
- WeatherKit- und Polleninformation-API-Clients, DTOs, Mapper und Repository-Implementierungen liegen in `Infrastructure`.
- Features dürfen keine konkrete Infrastruktur verwenden.
- Dependency Wiring passiert explizit in `App/Composition`.
- Keine globalen Singletons.
- Keine generischen `Manager`-Klassen.
- `make architecture-check` muss grün sein.

## 3. MVP Scope

### Enthalten

- Pollendaten laden.
- Allergie-Symptome erfassen.
- Symptom-Eingaben lokal für den MVP wieder anzeigen.
- Pollendaten und Symptome in einem einfachen Dashboard anzeigen.
- Loading-, Empty- und Error-State behandeln.
- Erweiterbare Domain- und Repository-Struktur schaffen.
- Unit Tests für Domain, Mapper, Repositories und ViewModels ergänzen.

### Nicht enthalten

- Account/Login.
- Cloud-Sync.
- Push Notifications.
- Medizinische Diagnosen oder Behandlungsempfehlungen.
- Mehrere Gesundheitsbereiche außerhalb Allergie.
- Langfristige Korrelationen oder Analytics.
- Externe Dependencies, solange Bordmittel reichen.

## 4. Vorgeschlagene Zielstruktur

```text
Cujana/
  App/
    Composition/
      AppDependencies.swift

  Features/
    AllergyDashboard/
      AllergyDashboardView.swift
      AllergyDashboardViewModel.swift
      AllergyDashboardModels.swift
      Components/

    SymptomEntry/
      SymptomEntryView.swift
      SymptomEntryViewModel.swift
      SymptomEntryModels.swift
      Components/

  Domain/
    Entities/
      AllergyOverview.swift
      PollenForecast.swift
      AllergySymptomEntry.swift
      LocationCoordinate.swift

    ValueObjects/
      InformationSourceKind.swift
      PollenType.swift
      PollenLevel.swift
      SymptomType.swift
      SymptomSeverity.swift

    UseCases/
      LoadAllergyOverviewUseCase.swift
      LoadPollenForecastUseCase.swift
      SaveAllergySymptomEntryUseCase.swift
      LoadAllergySymptomEntriesUseCase.swift

    Repositories/
      PollenRepository.swift
      SymptomEntryRepository.swift

    Errors/
      PollenDataError.swift
      SymptomEntryError.swift

  Infrastructure/
    Network/
      OpenMeteo/
        OpenMeteoPollenAPIClient.swift
        OpenMeteoPollenDTOs.swift
        OpenMeteoPollenMapper.swift

    Persistence/
      SymptomEntryStore.swift

    Repositories/
      OpenMeteoPollenRepository.swift
      LocalSymptomEntryRepository.swift
```

Diese Struktur ist ein Startpunkt. Sie soll beim Umsetzen bewusst einfach bleiben. Leere Ordner müssen nicht künstlich angelegt werden.

## 5. Abhängigkeiten zwischen Sub-Issues

```text
1 Domain-Grundlage
  ├── 2 OpenMeteo Integration
  ├── 3 Symptomerfassung Feature
  └── 4 Lokale Symptomdaten
        └── 5 Allergy Dashboard
              └── 6 App Composition / DI
                    └── 8 MVP Qualitäts-Gate

7 Tests läuft begleitend zu 1–6.
```

---

# GitHub EPIC

## Title

```text
EPIC: Weg zum MVP – Allergie, Pollendaten und Symptomerfassung
```

## Body

```markdown
## Ziel

Der MVP von Cujana soll Nutzer:innen ermöglichen, aktuelle Pollendaten zu sehen, Allergie-Symptome einzugeben und diese Informationen verständlich in der App angezeigt zu bekommen.

Der MVP umfasst bewusst nur den Allergie-Kontext. Die Architektur muss jedoch so aufgebaut sein, dass später weitere Gesundheits-, Umwelt- oder Kontextinformationen ergänzt werden können, ohne bestehende Features umzubauen.

## MVP Scope

Enthalten:

- Pollendaten von OpenMeteo abrufen
- Symptome eingeben
- Aktuell nur Allergie-Symptome unterstützen
- Pollendaten und Symptome anzeigen
- Erweiterbare Domain- und Repository-Struktur schaffen
- Fehler-, Loading- und Empty-State behandeln
- Architekturregeln aus `/docs/architecture` einhalten

Nicht enthalten:

- Account/Login
- Cloud-Sync
- Push Notifications
- Medizinische Diagnosen oder Behandlungsempfehlungen
- Mehrere Symptom-Kategorien außerhalb Allergie
- Langfristige Analytics/Korrelationen
- Externe Dependencies ohne ADR

## Architektur-Leitplanken

Cujana folgt der bestehenden Architektur:

- SwiftUI-first iOS-only App
- Modularer Monolith
- Feature-Slices unter `Cujana/Features`
- Fachmodelle, Use Cases und Repository-Protokolle unter `Cujana/Domain`
- OpenMeteo API Client, DTOs und Repository-Implementierungen unter `Cujana/Infrastructure`
- Dependency Wiring unter `Cujana/App/Composition`
- Keine direkte Nutzung von `URLSession`, `UserDefaults`, SwiftData oder CoreData in Features
- Keine globalen Singletons
- Keine generischen `Manager`-Klassen
- `make architecture-check` muss grün sein

## Sub-Issues

- [ ] Domain-Grundlage für Allergie-MVP erstellen
- [ ] OpenMeteo Pollendaten-Integration implementieren
- [ ] Symptomerfassung für Allergie implementieren
- [ ] Lokale Symptomdaten für MVP speichern und laden
- [ ] Allergy Dashboard zur Anzeige der MVP-Daten bauen
- [ ] App Composition und Dependency Injection für MVP verdrahten
- [ ] Tests für Domain, Mapping, Repositories und ViewModels ergänzen
- [ ] MVP Architektur- und Qualitäts-Gate finalisieren

## Akzeptanzkriterien

- Nutzer:innen können Pollendaten abrufen und sehen
- Nutzer:innen können Allergie-Symptome eingeben
- Nutzer:innen können eingegebene Symptome wieder sehen
- Die App zeigt Loading-, Empty- und Error-State
- OpenMeteo-Zugriff liegt vollständig in `Infrastructure`
- Features hängen nur von `Domain` und optional `DesignSystem` ab
- Domain enthält keine SwiftUI-, UIKit-, URLSession- oder Persistenzdetails
- Dependency Injection erfolgt explizit über Composition
- Relevante Unit Tests sind vorhanden
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:epic`, `mvp`, `area:product`

---

# Sub-Issues

## 1. Domain-Grundlage für Allergie-MVP erstellen

### Title

```text
Domain-Grundlage für Allergie-MVP erstellen
```

### Body

```markdown
## Ziel

Die fachliche Grundlage für den MVP schaffen, ohne UI-, Netzwerk- oder Persistenzdetails in die Domain zu ziehen.

## Hintergrund

Der MVP startet mit Allergie. Die Domain soll aber so benannt und modelliert sein, dass später weitere Informationsquellen oder Symptom-Kategorien ergänzt werden können.

## Aufgaben

- Domain Entities anlegen:
  - `AllergyOverview`
  - `PollenForecast`
  - `AllergySymptomEntry`
  - `LocationCoordinate`
- Value Objects anlegen:
  - `InformationSourceKind`
  - `PollenType`
  - `PollenLevel`
  - `SymptomType`
  - `SymptomSeverity`
- Repository-Protokolle definieren:
  - `PollenRepository`
  - `SymptomEntryRepository`
- Domain-Fehler definieren:
  - `PollenDataError`
  - `SymptomEntryError`
- Use Cases definieren:
  - `LoadAllergyOverviewUseCase`
  - `LoadPollenForecastUseCase`
  - `SaveAllergySymptomEntryUseCase`
  - `LoadAllergySymptomEntriesUseCase`

## Architekturvorgaben

- Ablage unter `Cujana/Domain`
- Domain darf nur von `Foundation` abhängen
- Keine Imports von `SwiftUI`, `UIKit`, `SwiftData`, `CoreData` oder Netzwerk-APIs
- Keine DTOs in der Domain
- Keine OpenMeteo-spezifischen Namen in Domain-Protokollen, außer fachlich notwendig

## Akzeptanzkriterien

- Domain-Modelle bilden Pollendaten und Allergie-Symptome ab
- Repository-Protokolle sind technologieunabhängig
- Use Cases sind isoliert testbar
- Domain-Tests decken zentrale Validierungen und Use-Case-Flows ab
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:domain`

---

## 2. OpenMeteo Pollendaten-Integration implementieren

### Title

```text
OpenMeteo Pollendaten-Integration implementieren
```

### Body

```markdown
## Ziel

Pollendaten von OpenMeteo über eine gekapselte Infrastructure-Integration abrufen und als Domain-Modelle bereitstellen.

## Aufgaben

- OpenMeteo API Client unter `Cujana/Infrastructure/Network/OpenMeteo` anlegen
- DTOs für die benötigte OpenMeteo-Response definieren
- Konkrete OpenMeteo-Parameter und Variablen vor der Implementierung gegen die aktuelle OpenMeteo-Dokumentation prüfen
- Mapper DTO → Domain implementieren
- `OpenMeteoPollenRepository` als Implementierung von `PollenRepository` erstellen
- Fehler aus Netzwerk/Decoding in Domain- oder App-Fehler mappen
- Unterstützung für Koordinaten im MVP vorsehen
- Keine direkte API-Nutzung in Features

## Architekturvorgaben

- `URLSession` nur in `Infrastructure`
- DTOs bleiben in `Infrastructure`
- Rückgabe an Domain/Use Cases erfolgt als Domain-Modell
- API Client muss testbar sein, zum Beispiel über injizierbaren HTTP-Client oder URLSession-Abstraktion
- Keine globalen Singletons

## Akzeptanzkriterien

- Pollendaten können für Koordinaten geladen werden
- Netzwerk-, Decoding- und API-Fehler werden sauber gemappt
- Mapper sind unit-getestet
- Repository ist mit Fake-API testbar
- Feature-Code enthält keinen OpenMeteo- oder `URLSession`-Zugriff
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:infrastructure`, `integration:openmeteo`

---

## 3. Symptomerfassung für Allergie implementieren

### Title

```text
Symptomerfassung für Allergie implementieren
```

### Body

```markdown
## Ziel

Nutzer:innen können im MVP Allergie-Symptome erfassen.

## MVP-Funktionsumfang

- Symptom auswählen
- Stärke/Schweregrad auswählen
- Optional Notiz erfassen
- Zeitpunkt der Eingabe speichern
- Eingabe absenden/speichern
- Erfolgs-, Fehler- und Validierungszustand anzeigen

## Aufgaben

- Feature unter `Cujana/Features/SymptomEntry` anlegen
- `SymptomEntryView` erstellen
- `SymptomEntryViewModel` erstellen
- UI-Models für Presentation State definieren
- ViewModel ruft `SaveAllergySymptomEntryUseCase` auf
- Validierungsfehler nutzerfreundlich anzeigen
- Loading-/Saving-State behandeln

## Architekturvorgaben

- View enthält keine Fachlogik
- ViewModel koordiniert UI-State und ruft Use Cases auf
- Kein direkter Zugriff auf Persistenz oder Infrastruktur aus dem Feature
- Keine globalen Singletons
- Keine technischen Fehlermeldungen direkt in der UI anzeigen

## Akzeptanzkriterien

- Allergie-Symptom kann eingegeben werden
- Schweregrad kann eingegeben werden
- Optionaler Notiztext kann eingegeben werden
- Ungültige Eingaben werden abgefangen
- Erfolgreiches Speichern wird im UI-State sichtbar
- ViewModel ist mit Fake-Use-Case testbar
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:feature`, `feature:symptom-entry`

---

## 4. Lokale Symptomdaten für MVP speichern und laden

### Title

```text
Lokale Symptomdaten für MVP speichern und laden
```

### Body

```markdown
## Ziel

Symptom-Eingaben sollen im MVP lokal gespeichert und wieder geladen werden können.

## Aufgaben

- `SymptomEntryRepository` implementieren
- Minimalen lokalen Store unter `Cujana/Infrastructure/Persistence` anlegen
- `LocalSymptomEntryRepository` unter `Cujana/Infrastructure/Repositories` erstellen
- Persistenzmodell nicht als Domain-Modell missbrauchen
- Mapper Persistenzmodell → Domain und Domain → Persistenzmodell definieren, falls nötig
- Fehler sauber in `SymptomEntryError` oder App-Fehler mappen

## Architekturvorgaben

- Persistenz bleibt hinter Repository-Protokollen
- Keine direkte Nutzung von `UserDefaults`, SwiftData oder CoreData in Features
- Keine Persistenzdetails in Domain
- Kleine, austauschbare MVP-Lösung bevorzugen
- Neue Persistenztechnologie nur mit ADR, wenn sie produktiven App-Code grundlegend prägt

## Akzeptanzkriterien

- Symptom-Einträge können gespeichert werden
- Symptom-Einträge können geladen werden
- Leerer Zustand wird sauber repräsentiert
- Fehlerfälle sind testbar
- Repository ist mit In-Memory- oder Fake-Store testbar
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:infrastructure`, `area:persistence`

---

## 5. Allergy Dashboard zur Anzeige der MVP-Daten bauen

### Title

```text
Allergy Dashboard zur Anzeige der MVP-Daten bauen
```

### Body

```markdown
## Ziel

Nutzer:innen sehen im MVP eine einfache Übersicht aus Pollendaten und erfassten Allergie-Symptomen.

## MVP-Funktionsumfang

- Pollendaten anzeigen
- Aktuelle oder letzte Symptom-Eingaben anzeigen
- Loading-State anzeigen
- Empty-State anzeigen
- Error-State anzeigen
- Einstieg in die Symptomerfassung anbieten

## Aufgaben

- Feature unter `Cujana/Features/AllergyDashboard` anlegen
- `AllergyDashboardView` erstellen
- `AllergyDashboardViewModel` erstellen
- Presentation Models für Pollendaten und Symptome definieren
- `LoadAllergyOverviewUseCase` verwenden
- UI-Komponenten bewusst klein halten
- Optional wiederverwendbare visuelle Bausteine ins `DesignSystem` verschieben, wenn sie wirklich generisch sind

## Architekturvorgaben

- View zeigt Zustand an und leitet Nutzeraktionen weiter
- ViewModel lädt Daten über Use Case
- Kein direkter Zugriff auf OpenMeteo, URLSession oder lokale Persistenz
- Domain-Modelle werden im ViewModel in UI-Modelle gemappt
- Fehlerzustand ist Teil des ViewState

## Akzeptanzkriterien

- Pollendaten werden verständlich angezeigt
- Symptomdaten werden verständlich angezeigt
- Loading-, Empty- und Error-State sind sichtbar umgesetzt
- Nutzer:innen können von der Übersicht zur Symptomerfassung gelangen
- ViewModel-Zustandsübergänge sind getestet
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:feature`, `feature:allergy-dashboard`

---

## 6. App Composition und Dependency Injection für MVP verdrahten

### Title

```text
App Composition und Dependency Injection für MVP verdrahten
```

### Body

```markdown
## Ziel

Die MVP-Features werden über explizite Dependency Injection mit echten Repository-Implementierungen verbunden.

## Aufgaben

- `AppDependencies` um MVP-Abhängigkeiten ergänzen
- Echte Implementierungen in `Cujana/App/Composition` erzeugen
- Repositories an Use Cases übergeben
- Use Cases an ViewModels übergeben
- Startscreen oder Navigation zum Allergy Dashboard verdrahten
- Feature-lokale Navigation sauber halten

## Architekturvorgaben

- Constructor Injection verwenden
- Keine globalen Service-Locator
- Keine `static let shared` App-Services
- App Composition erzeugt echte Implementierungen
- Tests nutzen Fakes oder In-Memory-Implementierungen

## Akzeptanzkriterien

- App startet in den MVP-Flow
- Allergy Dashboard kann Daten laden
- Symptom Entry kann Daten speichern
- Dependencies sind explizit sichtbar
- Keine Feature-Klasse erzeugt konkrete Infrastructure-Implementierungen
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:app`, `area:composition`

---

## 7. Tests für Domain, Mapping, Repositories und ViewModels ergänzen

### Title

```text
Tests für Domain, Mapping, Repositories und ViewModels ergänzen
```

### Body

```markdown
## Ziel

Der MVP soll durch schnelle Tests abgesichert werden, insbesondere dort, wo Fachlogik, Mapping und UI-State entstehen.

## Aufgaben

- Domain-Use-Cases testen
- Value Objects und Validierungen testen
- OpenMeteo DTO-Decoding testen
- OpenMeteo DTO → Domain Mapping testen
- Repository-Implementierungen mit Fake-API oder In-Memory-Store testen
- `SymptomEntryViewModel` testen
- `AllergyDashboardViewModel` testen
- Fehler-, Loading-, Empty- und Content-State testen

## Architekturvorgaben

- Neue Fachlogik braucht Unit Tests
- Tests nutzen Fakes statt echter Netzwerke
- Swift Testing für neue Unit Tests bevorzugen
- XCTest bleibt für UI Tests zulässig
- Kein Mischen von `Testing` und `XCTest` im selben Testfile

## Akzeptanzkriterien

- Zentrale Use Cases sind getestet
- Mapper sind getestet
- ViewModel-State-Transitions sind getestet
- Kein Test benötigt echtes Netzwerk
- Tests sind lokal ausführbar
- `make architecture-check` ist grün
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:tests`

---

## 8. MVP Architektur- und Qualitäts-Gate finalisieren

### Title

```text
MVP Architektur- und Qualitäts-Gate finalisieren
```

### Body

```markdown
## Ziel

Vor Abschluss des MVP sicherstellen, dass der Flow nutzbar ist und die Architekturregeln eingehalten werden.

## Aufgaben

- MVP-Flow manuell durchspielen:
  - App starten
  - Pollendaten laden
  - Symptom erfassen
  - Symptomdaten wieder anzeigen
  - Fehlerzustand prüfen
- `make architecture-check` ausführen
- Tests ausführen
- Prüfen, ob neue Dependencies oder Architekturabweichungen ein ADR benötigen
- Prüfen, ob technische Fehlermeldungen in der UI vermieden werden
- Prüfen, ob Erweiterbarkeit ohne generische Over-Engineering-Abstraktionen gegeben ist
- Offene Nicht-MVP-Themen als Follow-up-Issues notieren

## Architekturvorgaben

- Keine stillschweigenden Ausnahmen von Architekturregeln
- Abweichungen nur mit ADR oder dokumentiertem Follow-up
- Keine globalen Singletons
- Keine `Manager`-Klassen
- Features greifen nicht direkt auf Infrastruktur zu

## Akzeptanzkriterien

- MVP-Flow funktioniert end-to-end
- `make architecture-check` ist grün
- Relevante Tests sind grün
- Bekannte Einschränkungen sind dokumentiert
- Follow-up-Issues für nach dem MVP sind identifiziert
```

Vorgeschlagene Labels: `type:task`, `mvp`, `area:quality`
