# Datenquellen für AllergieManagement

Diese Datei sammelt mögliche Datenquellen für eine selbst hostbare Allergie-Management-Web-App. Ziel ist, Symptome, mögliche Auslöser und Umweltdaten zusammenzuführen, ohne die App unnötig abhängig von proprietären Diensten zu machen.

> Stand: 2026-05-04. Vor der Implementierung sollten Verfügbarkeit, Lizenzbedingungen, Rate Limits und regionale Abdeckung nochmals geprüft werden.

## Anforderungen an Datenquellen

- **Selbst hostbar kompatibel:** Die App muss ohne proprietäre Backend-Pflicht laufen. Externe APIs dürfen optional angebunden werden.
- **EU/AT-tauglich:** Österreich und Deutschland sollten gut abgedeckt sein; idealerweise auch Schweiz/EU.
- **Historisierung:** Werte sollten lokal gespeichert werden können, damit später Zusammenhänge zwischen Symptomen und Umweltfaktoren analysiert werden können.
- **Datenschutz:** Standortdaten nur grob speichern, wenn möglich. Exakte GPS-Daten nur mit expliziter Zustimmung.
- **Fallback-fähig:** Wenn eine Quelle ausfällt, soll die App weiter nutzbar bleiben und manuelle Einträge erlauben.

## Kurzempfehlung

Für eine erste Version bietet sich eine modulare Quellenstrategie an:

1. **Open-Meteo** für Wetter, Luftqualität und teils Pollen-/Aeroallergen-Daten, weil es ohne API-Key nutzbar ist und gut zu Self-Hosting passt.
2. **Meteostat** oder nationale Wetterdienste als optionale historische Wetterquelle.
3. **Umweltbundesamt / EEA / OpenAQ** für Luftqualität, Ozon, Feinstaub und NO₂.
4. **Pollenwarndienst Österreich / nationale Pollenservices** als manuelle oder halbautomatische Referenz, falls keine stabile offene API verfügbar ist.
5. Eine interne **Provider-Abstraktion**, damit Quellen austauschbar bleiben.

## Pollen- und Allergendaten

### Open-Meteo Air Quality / Pollen

**Eignung:** Sehr guter Startpunkt für MVP und Self-Hosting-nahe Architektur.

Open-Meteo bietet APIs ohne API-Key und mit freier Nutzung für nicht-kommerzielle bzw. faire Nutzung. Neben Wetterdaten gibt es auch Air-Quality-Daten. Je nach Region/Modell können Pollenparameter verfügbar sein, z. B. Birke, Gräser, Beifuß, Ambrosia/Weed-Pollen oder ähnliche Kategorien.

**Mögliche Datenpunkte:**

- Pollenbelastung nach Art, soweit verfügbar
- Feinstaub PM10/PM2.5
- Ozon
- Stickstoffdioxid
- Schwefeldioxid
- Kohlenmonoxid
- UV-Index
- Wetterdaten über separate Forecast-/Archive-APIs

**Vorteile:**

- Kein API-Key notwendig
- Einfache HTTP/JSON-Schnittstelle
- Gut für Docker/self-hosted Setups
- Wetter und Luftqualität aus einer Anbieterfamilie
- Gute Entwicklerfreundlichkeit

**Nachteile / Risiken:**

- Pollenabdeckung und Modellqualität müssen regional getestet werden
- Keine medizinische Diagnosequelle
- Lizenz/Fair-Use für kommerzielle Nutzung prüfen

**Implementierungsidee:**

```text
GET /v1/air-quality?latitude=48.2082&longitude=16.3738&hourly=pm10,pm2_5,ozone,nitrogen_dioxide,uv_index
```

Pollenparameter sollten anhand der aktuellen Open-Meteo-Dokumentation validiert und nur aktiviert werden, wenn die API sie für die Zielregion unterstützt.

### Pollenwarndienst Österreich

**Eignung:** Fachlich sehr relevant für Österreich, aber API-Verfügbarkeit muss geprüft werden.

Der österreichische Pollenwarndienst ist für Österreich naheliegend und bietet regionale Polleninformationen. Für eine App in Österreich wäre diese Quelle fachlich attraktiv. Häufig sind solche Dienste jedoch primär für Webseiten/Apps ausgelegt und nicht zwingend als offene, stabile Public API dokumentiert.

**Vorteile:**

- Hohe regionale Relevanz für Österreich
- Fachlich näher an Allergiker:innen als reine Wettermodelle
- Gute Nutzererwartung für AT

**Nachteile / Risiken:**

- Öffentliche API eventuell nicht dokumentiert oder nicht dauerhaft nutzbar
- Nutzungsrechte und Automatisierung müssen geklärt werden
- Scraping sollte vermieden werden, wenn keine ausdrückliche Erlaubnis besteht

**Empfehlung:**

- Als potenziellen Premium-/Regionalprovider vormerken.
- Kontaktaufnahme oder Lizenzprüfung vor produktiver Nutzung.
- Nicht als einzige Quelle für MVP einplanen.

### Deutscher Wetterdienst / nationale Polleninformationen

**Eignung:** Interessant für Deutschland; Details und automatisierbare Schnittstellen prüfen.

Der DWD veröffentlicht Pollenflug-Gefahrenindizes und Wetterdaten. Für Deutschland kann diese Quelle sehr wertvoll sein. Für die App sollte geprüft werden, ob die relevanten Daten maschinenlesbar, lizenzkompatibel und regelmäßig abrufbar sind.

**Vorteile:**

- Offizielle Quelle für Deutschland
- Gute fachliche Akzeptanz
- Potenziell stabile Daten

**Nachteile / Risiken:**

- Regionale Struktur muss auf Nutzerstandort gemappt werden
- Datenformate können weniger komfortabel sein als moderne JSON-APIs
- Für Österreich nur eingeschränkt relevant

### Weitere nationale Pollenquellen

Für spätere Länderabdeckung können Provider ergänzt werden:

- Schweiz: MeteoSchweiz / Allergiezentrum Schweiz prüfen
- EU/Europa: Copernicus Atmospheric Monitoring Service prüfen
- Lokale Gesundheits-/Wetterdienste je Land prüfen

Die App sollte diese Quellen nicht fest verdrahten, sondern über ein gemeinsames Interface anbinden.

## Luftqualität und Umweltbelastung

### OpenAQ

**Eignung:** Gute offene Quelle für Messstationsdaten zur Luftqualität.

OpenAQ aggregiert Luftqualitätsmessungen aus vielen öffentlichen Quellen. Nützlich für PM10, PM2.5, NO₂, Ozon und weitere Schadstoffe.

**Vorteile:**

- Offene, API-basierte Datenquelle
- Viele internationale Messstationen
- Gut geeignet für historische und aktuelle Messwerte

**Nachteile / Risiken:**

- Stationsabdeckung variiert regional
- Messstation ist nicht immer nahe am Nutzerstandort
- Datenqualität hängt von Ursprungssystemen ab

**Use Case:**

- Aktuelle Luftqualität rund um groben Standort
- Historische Belastung am Symptomtag
- Vergleich von Symptomstärke mit PM/Ozon/NO₂

### Umweltbundesamt Österreich / Luftgütemessnetze

**Eignung:** Sehr relevant für Österreich, insbesondere Ozon, PM10/PM2.5 und NO₂.

Österreichische Luftgütedaten sind fachlich wichtig. Es sollte geprüft werden, welche maschinenlesbaren Schnittstellen oder Open-Data-Datensätze verfügbar sind.

**Vorteile:**

- Offizielle Daten für Österreich
- Hohe Glaubwürdigkeit
- Gute Ergänzung zu Modell-/API-Daten

**Nachteile / Risiken:**

- Schnittstellen können komplexer sein
- Regionale Messstationen müssen sinnvoll zugeordnet werden
- Historische Datenverfügbarkeit prüfen

### European Environment Agency / EEA

**Eignung:** Interessant für EU-weite Luftqualitätsdaten.

Für langfristige EU-Abdeckung kann die EEA als Datenquelle oder Referenz dienen. Für den MVP ist eine einfachere API wie OpenAQ oder Open-Meteo vermutlich schneller integrierbar.

## Wetterdaten

### Open-Meteo Weather Forecast & Archive

**Eignung:** Sehr gut für MVP.

Open-Meteo liefert Wettervorhersage und historische Wetterdaten per HTTP/JSON. Für Symptomkorrelationen sind vor allem Temperatur, Luftfeuchtigkeit, Luftdruck, Niederschlag, Wind und Wetterwechsel interessant.

**Mögliche Datenpunkte:**

- Temperatur
- Luftfeuchtigkeit
- Luftdruck
- Niederschlag
- Windgeschwindigkeit
- Bewölkung
- UV-Index
- Wettercode

**Vorteile:**

- Kein API-Key
- Forecast und Archive verfügbar
- Einfache Integration

### Meteostat

**Eignung:** Gute historische Wetterdatenquelle.

Meteostat bietet historische Wetter- und Klimadaten und kann als Ergänzung zu Open-Meteo dienen, vor allem wenn nachträglich Einträge für vergangene Tage ergänzt werden.

**Vorteile:**

- Historische Daten stark
- Python-Ökosystem gut nutzbar, aber auch API/Exports prüfen

**Nachteile:**

- Für eine reine Web-App muss geprüft werden, ob API/Hosting gut passt
- Lizenzbedingungen prüfen

### Nationale Wetterdienste

Für Länder mit guter Open-Data-Strategie können nationale Wetterdienste angebunden werden. Beispiele:

- GeoSphere Austria für Österreich
- Deutscher Wetterdienst für Deutschland
- MeteoSchweiz für Schweiz

Diese Quellen sind fachlich wertvoll, aber oft aufwändiger als Open-Meteo.

## Weitere mögliche Kontextdaten

### Kalender / Tageskontext

Optional und nur mit Zustimmung:

- Wochentag, Wochenende, Feiertag
- Arbeitstag vs. freier Tag
- Schlaf-/Stress-Selbsteinschätzung

Feiertage können offline oder über eine kleine lokale Library berechnet werden, statt externe APIs zu nutzen.

### Infekte / allgemeine Gesundheitslage

Vorsichtig verwenden, da medizinisch sensibel:

- Nutzer kann manuell „Erkältung/Infekt“ markieren
- Keine automatische Diagnose
- Keine unnötige Fremddatenintegration in MVP

### Indoor-Auslöser

Nicht API-basiert, aber wichtig für die App:

- Haustiere/Katze/Hund
- Staub/Putzen
- Schimmelverdacht
- Rasenmähen/Gartenarbeit
- Neue Lebensmittel
- Sport/Anstrengung
- Medikamente
- Zyklus/Hormone, optional und datenschutzsensibel

## Architekturvorschlag für Datenquellen

### Provider-Interface

Alle Quellen sollten über ein gemeinsames Interface eingebunden werden:

```ts
interface EnvironmentalDataProvider {
  id: string;
  displayName: string;
  supportsForecast: boolean;
  supportsHistory: boolean;
  getCurrent(input: EnvironmentalQuery): Promise<EnvironmentalSnapshot>;
  getHistory(input: EnvironmentalHistoryQuery): Promise<EnvironmentalSnapshot[]>;
}
```

### Normalisiertes Datenmodell

```ts
type EnvironmentalSnapshot = {
  source: string;
  observedAt: string;
  location: {
    latitude?: number;
    longitude?: number;
    geohash?: string;
    label?: string;
    precision: 'exact' | 'approximate' | 'region';
  };
  weather?: {
    temperatureC?: number;
    relativeHumidityPercent?: number;
    pressureHPa?: number;
    precipitationMm?: number;
    windSpeedKmh?: number;
  };
  airQuality?: {
    pm10?: number;
    pm25?: number;
    ozone?: number;
    nitrogenDioxide?: number;
    sulphurDioxide?: number;
    carbonMonoxide?: number;
    europeanAqi?: number;
  };
  pollen?: {
    grass?: number;
    birch?: number;
    alder?: number;
    hazel?: number;
    mugwort?: number;
    ragweed?: number;
    olive?: number;
    unit?: 'index' | 'grains_per_m3' | 'unknown';
  };
  raw?: unknown;
};
```

### Wichtige Designentscheidungen

- Rohdaten optional speichern, aber klar versionieren.
- Normalisierte Felder für App-Logik verwenden.
- Standort standardmäßig runden, z. B. auf 2 Dezimalstellen oder Geohash mittlerer Präzision.
- Pro Quelle `source`, `fetchedAt`, `observedAt` und `licenseHint` speichern.
- Daten nicht als medizinische Wahrheit darstellen, sondern als Kontext.

## MVP-Empfehlung

Für die erste Version:

- Open-Meteo Weather Forecast
- Open-Meteo Archive für nachträgliche Einträge
- Open-Meteo Air Quality für Ozon/Feinstaub/NO₂/UV
- Pollenwerte über Open-Meteo testen und feature-flaggen
- Manuelle Auslöser als Hauptfunktion
- Datenquellen-Status in Admin/Settings anzeigen

Nicht im MVP erzwingen:

- Scraping von Pollen-Webseiten
- Medizinische Interpretation
- Länderübergreifende Spezialprovider
- Exakte Standorthistorie

## Offene Prüfaufgaben

- [ ] Prüfen, welche Pollenparameter Open-Meteo aktuell für Wien/Österreich liefert.
- [ ] Lizenz/Fair-Use für Open-Meteo im geplanten Nutzungsmodell prüfen.
- [ ] Pollenwarndienst Österreich kontaktieren oder Nutzungsbedingungen/API-Verfügbarkeit prüfen.
- [ ] Offizielle österreichische Luftqualitätsdaten-Schnittstellen evaluieren.
- [ ] Datenmodell für EnvironmentalSnapshot finalisieren.
- [ ] Cache-/Retry-Strategie definieren.
- [ ] UI-Copy: Umweltwerte als „mögliche Hinweise“, nicht als Ursachenbeweis formulieren.

## Produkt-Hinweis

Die App sollte Korrelationen vorsichtig formulieren:

- Gut: „An Tagen mit hoher Ozonbelastung hast du häufiger Symptome dokumentiert.“
- Schlecht: „Ozon verursacht deine Symptome.“

Ziel ist ein persönliches Beobachtungswerkzeug, keine Diagnose- oder Therapieentscheidung.
