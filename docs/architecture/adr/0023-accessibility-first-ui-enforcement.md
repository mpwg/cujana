# ADR-0023: Accessibility-first UI-Regeln werden statisch abgesichert

Status: Akzeptiert  
Datum: 2026-05-11

## Kontext

Cujana soll Accessibility Nutrition Labels ehrlich aktivieren können. Dafür reicht es
nicht, einzelne Labels nachzurüsten: UI-Code muss Dynamic Type, VoiceOver,
Reduce Motion, Kontrast und Dark Mode als Standardpfad behandeln.

Mehrere Accessibility-Risiken sind gut statisch erkennbar: feste SwiftUI-Schriftgrößen,
`minimumScaleFactor` als Ersatz für responsives Layout und `lineLimit(1)` als Quelle
für abgeschnittene Texte bei großen Accessibility-Schriftgrößen.

## Entscheidung

SwiftLint verbietet diese Muster appweit:

- direkte `Font.system(size:)`-Definitionen
- direkte `Font.system(...)`-Factories
- `.minimumScaleFactor(...)`
- `.lineLimit(1)`

UI-Code verwendet stattdessen Dynamic-Type-Textstyles, mehrzeilige Layouts,
semantische Tokens und adaptive Color Assets. Ergänzend gibt es einen UI-Test mit
`performAccessibilityAudit()`, der Hauptscreens gegen Xcodes Accessibility-Audit prüft.

## Konsequenzen

Neue Komponenten müssen accessibility-first gebaut werden. Wenn ein Layout bei großen
Textgrößen nicht passt, darf Text nicht verkleinert oder abgeschnitten werden; das Layout
muss umbrechen, wachsen oder alternative Dichte verwenden.

Die Regeln sind bewusst streng. Ausnahmen brauchen eine bewusste Architekturentscheidung
und dürfen nicht als lokaler Workaround in Feature-Code landen.
