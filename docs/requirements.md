# Anforderungsdokument: Cujana App

## 1. Zielbild

Die iOS-App soll Menschen mit Allergien dabei unterstützen, akute Symptome, mögliche Auslöser und relevante Umweltfaktoren zusammenzuführen. Ziel ist kein medizinisches Diagnosesystem, sondern ein persönliches Tagebuch mit Kontextdaten, das Muster sichtbar macht und Gespräche mit Ärztinnen, Ärzten oder Allergologinnen erleichtert.

Die Anwendung muss ohne eigenes Backend funktionieren. Sie soll persönliche Gesundheitsdaten lokal speichern und externe Datenquellen nur gekapselt über die Infrastruktur-Schicht anbinden.

## 2. Kernidee

Nutzerinnen und Nutzer erfassen Symptome möglichst schnell und niederschwellig:

- Was spüre ich gerade?
- Wie stark ist es?
- Wo bin ich ungefähr?
- Was könnte der Auslöser sein?
- Welche Medikamente oder Maßnahmen habe ich genommen?
- Welche Umweltbedingungen herrschten zu diesem Zeitpunkt?

Die App ergänzt diese Einträge automatisch mit externen Kontextdaten wie Pollenflug, Ozon, Feinstaub, Wetter, Luftfeuchtigkeit oder Wind. Daraus entstehen später Trends, Hinweise und Reports.

## 3. Zielgruppe

Primäre Zielgruppen:

- Menschen mit saisonalen Allergien, z. B. Gräser, Birke, Ragweed, Hausstaub
- Menschen mit Tierhaarallergien, z. B. Katze, Hund, Pferd
- Eltern, die Symptome für Kinder dokumentieren wollen
- Personen mit Asthma- oder Atemwegsbeschwerden, die Umweltfaktoren beobachten möchten
- Allergologinnen und Ärzte als indirekte Zielgruppe über exportierbare Berichte

## 4. Must-have Anforderungen

### 4.1 Kein Backend

Die iOS App muss ohne Backend auskommen.

### 4.2 Symptomtagebuch

Nutzerinnen und Nutzer müssen akute Symptome eintragen können.

Symptomfelder:

- Zeitpunkt
- Dauer oder Status: akut, abgeklungen, anhaltend
- Schweregrad, z. B. 0–10 oder leicht/mittel/stark/sehr stark
- Symptome:
  - Niesen
  - laufende Nase
  - verstopfte Nase
  - juckende Augen
  - tränende Augen
  - Husten
  - Atemnot
  - Hautreaktion
  - Kopfschmerz
  - Müdigkeit
  - Schlafprobleme
  - freie Notiz
- betroffene Körperbereiche
- optional Foto, z. B. Hautreaktion oder Augenrötung

Die Erfassung muss mobil gut funktionieren und in unter einer Minute möglich sein.

### 4.3 Auslöser erfassen

Mögliche Trigger müssen manuell auswählbar und frei ergänzbar sein.

Beispiele:

- Katze
- Hund
- Rasenmäher
- frisch gemähter Rasen
- Spaziergang im Park
- Wald
- Staub
- Reinigung
- Schimmel
- neue Lebensmittel
- Parfum
- Rauch
- Sport
- Wetterwechsel
- Heizungsluft
- Klimaanlage
- Bettwäsche gewechselt
- Fenster offen

Trigger sollen als Tags modelliert werden, damit Nutzerinnen und Nutzer eigene Begriffe verwenden können.

### 4.4 Automatische Umwelt- und Allergendaten

Für jeden Eintrag sollen, sofern aktiviert, relevante externe Daten gespeichert werden.

Pflichtdaten als Konzept:

- Wetter:
  - Temperatur
  - Luftfeuchtigkeit
  - Luftdruck
  - Windrichtung
  - Windgeschwindigkeit
  - Niederschlag
- Luftqualität:
  - Ozon
  - Feinstaub PM2.5
  - Feinstaub PM10
  - Stickstoffdioxid NO2
  - optional Schwefeldioxid SO2 und Kohlenmonoxid CO
- Allergene:
  - Pollenarten je nach Region
  - Belastungsstufe pro Allergen
  - Prognose für kommende Tage

Die App muss speichern, welche Datenquelle verwendet wurde und wann die Daten abgefragt wurden.

### 4.5 Standortmodell

Die Anwendung soll mehrere Standortmodi unterstützen:

- manuelle Stadt/Region
- gespeicherte Lieblingsorte, z. B. Zuhause, Arbeit, Schule
- optional grobe Standorterfassung über Core Location
- optional grobe Standorterfassung ohne exakte Adresse

Privacy-by-default:

- Exakte Koordinaten dürfen nicht zwingend erforderlich sein.
- Nutzerinnen und Nutzer müssen Datenquellen auch nur für einen manuellen Ort nutzen können.

### 4.6 Verlauf und Suche

Nutzerinnen und Nutzer müssen Einträge durchsuchen und filtern können.

Filter:

- Zeitraum
- Symptomtyp
- Stärke
- Trigger
- Ort
- Allergen
- Luftqualitätswert
- Medikament/Maßnahme
- freie Textsuche

Ansichten:

- chronologische Liste
- Kalenderansicht
- Tagesdetail
- Wochen-/Monatsübersicht

### 4.7 Auswertungen und Muster

Die App soll aus Einträgen und Kontextdaten verständliche Hinweise ableiten.

Beispiele:

- Symptome häufen sich bei hoher Gräserbelastung.
- Beschwerden treten oft nach Kontakt mit Katzen auf.
- Atemwegsbeschwerden korrelieren mit erhöhtem Ozon.
- Symptome sind an Tagen nach Rasenmähen stärker.
- Medikamente reduzieren durchschnittlich die Dauer oder Intensität.

Wichtig:

- Hinweise dürfen nicht als Diagnose formuliert werden.
- Die App soll vorsichtig formulieren: „Es gibt einen möglichen Zusammenhang“, nicht „Das ist die Ursache“.

### 4.8 Berichte und Export

Die Anwendung muss Reports erzeugen können.

Exportformate:

- PDF
- CSV
- JSON Backup/Export

Reportinhalte:

- Zeitraum
- Symptomübersicht
- häufige Trigger
- Umwelt- und Pollendaten
- Medikamenten-/Maßnahmenübersicht
- ausgewählte Einträge im Detail
- Notizen der Nutzerin/des Nutzers

Ziel: Ein Report soll für Arztgespräche oder Allergietests hilfreich sein.

## 5. Datenschutz und Sicherheit

Die App verarbeitet sensible Gesundheitsdaten. Daher gelten hohe Anforderungen.

Pflicht:

- Privacy-by-default
- keine Telemetrie ohne explizites Opt-in
- keine externen Trackingdienste
- klare Trennung von persönlichen Einträgen und öffentlichen Umweltquellen
- Datenexport und Datenlöschung pro Nutzerprofil

## 7. Datenquellen

Die Anwendung soll Datenquellen modular anbinden. Verbindlich für den aktuellen MVP sind WeatherKit für Wetterdaten und Polleninformation für Pollendaten gemäß [ADR-0012](architecture/adr/0012-weatherkit-and-polleninformation-sources.md).

Mögliche Quellen:

- WeatherKit für Wetter
- Polleninformation für Pollendaten und Allergierisiken
- nationale Umweltagenturen
- Copernicus Atmosphere Monitoring Service
- eigene CSV/API-Importer
- manuelle Pollenbelastung, falls keine Quelle verfügbar ist

Architekturanforderung:

- Domain-Repository-Protokolle für externe Daten
- Caching, damit APIs nicht unnötig belastet werden
- Fallback, wenn ein Provider ausfällt
- Quellen-Metadaten pro gespeicherter Messung

## 8. UX Anforderungen

Die App soll ruhig, vertrauenswürdig und nicht medizinisch-kalt wirken.

Prinzipien:

- schneller Akuteintrag prominent erreichbar
- iPhone- und iPad-first, Mac Catalyst unterstützt
- klare Sprache ohne medizinischen Jargon
- verständliche Trends statt komplexer Statistik
- keine Angstmacherei
- Barrierefreiheit beachten
- Dark Mode optional

Wichtige Screens:

- Dashboard „Wie geht es dir gerade?“
- Schnell-Eintrag
- Detail-Eintrag
- Verlauf
- Umwelt heute
- Pollen heute
- Insights
- Reports
- Einstellungen
- Datenquellenstatus
- Benutzer/Profile

## 9. Kreative Erweiterungen

### 9.1 Allergie-Wetterkarte

Eine Karte zeigt Pollen-, Ozon- und Luftqualitätsbelastung für gespeicherte Orte. Besonders hilfreich für Spaziergänge, Schulwege oder Urlaubsplanung.

### 9.2 Trigger-Detektiv

Ein geführter Analysemodus stellt Fragen:

- Warst du draußen?
- Gab es Tierkontakt?
- Wurde Rasen gemäht?
- Waren Fenster offen?
- Hast du neue Lebensmittel gegessen?

Daraus entsteht ein strukturierter Eintrag statt einer bloßen Notiz.

### 9.3 Familienmodus

Mehrere Profile in einem Haushalt:

- Eltern erfassen für Kinder
- eigene Trigger je Kind
- getrennte Reports
- Erinnerungen pro Person

### 9.4 Medikamenten- und Maßnahmenwirkung

Nutzerinnen und Nutzer können dokumentieren:

- Antihistaminikum genommen
- Nasenspray verwendet
- Augentropfen verwendet
- geduscht
- Kleidung gewechselt
- Luftreiniger eingeschaltet
- Fenster geschlossen

Die App kann später zeigen, welche Maßnahmen subjektiv geholfen haben.



### 9.7 Urlaubs- und Ortsvergleich

Vor Reisen kann die App Orte vergleichen:

- aktuelle Pollenbelastung
- typische saisonale Belastung
- Luftqualität
- bisherige persönliche Reaktionen an ähnlichen Orten

### 9.8 Arztmodus

Ein temporärer, datenschutzfreundlicher Link zeigt einen Report ohne Login oder mit PIN. Der Link läuft automatisch ab.



### 9.10 Persönliche Allergie-Saison

Die App erkennt wiederkehrende Zeiträume, z. B. „deine Birkenphase beginnt meist Mitte März“, und zeigt sanfte Vorbereitungs-Hinweise.



## 11. Nicht-Ziele für Version 1

Nicht Bestandteil der ersten Version:

- medizinische Diagnose
- Therapieempfehlung im engeren Sinn
- automatische Notfallerkennung
- verpflichtende Cloud-Synchronisation
- öffentliche Social Features
- KI-basierte Diagnoseaussagen

## 14. Offene Fragen

- Welche Region soll zuerst optimal unterstützt werden, z. B. Österreich, Deutschland, EU allgemein?
- Welche Pollenquelle ist zuverlässig und rechtlich nutzbar?
- Soll die App primär für Einzelpersonen oder Familien starten?
- Soll SQLite dauerhaft Standard bleiben oder nur Entwicklungsmodus sein?
- Wie stark sollen medizinische Inhalte kuratiert werden?
- Soll es eine native Mobile App später geben oder reicht PWA?
