# ADR-0015: Schriftgrößen werden über UI-Tokens geführt

Status: Akzeptiert  
Datum: 2026-05-11

## Kontext

Feature-Views konnten bisher eigene `Font.system(size:)`-Aufrufe verwenden. Dadurch
entstanden neue Magic Numbers in der UI, obwohl die App bereits Design-, Semantic- und
Component-Tokens für visuelle Entscheidungen nutzt.

Gerade die Einträge-Timeline braucht eine ruhige, konsistente Typografie. Direkte
Schriftgrößen in Feature-Code erschweren diese Konsistenz und machen spätere
Designanpassungen unnötig verteilt.

## Entscheidung

SwiftLint verbietet direkte `.system(... size:)`-Fontdefinitionen außerhalb von
`Cujana/DesignSystem`. Feature-Code verwendet stattdessen `TypographyToken` oder
komponentenspezifische Font-Tokens.

Die Token-Definitionen bleiben im DesignSystem erlaubt, weil dort die semantische
Zuordnung von Größe, Gewicht und Einsatzkontext stattfindet.

## Konsequenzen

Neue Schriftgrößen bekommen einen sprechenden Namen und werden bewusst Teil des
Designsystems. Feature-Views bleiben näher an der Produktästhetik und enthalten weniger
visuelle Implementierungsdetails.

Für neue UI-Muster muss zuerst entschieden werden, ob ein bestehender Typography-Token
passt oder ein neuer semantischer beziehungsweise komponentenspezifischer Token nötig
ist.

## Alternativen

Nur `size: 18` zu verbieten wurde verworfen, weil dadurch das eigentliche Problem
bestehen bleibt: Feature-Code könnte weiterhin beliebige andere Schriftgrößen direkt
setzen.

Eine globale Magic-Number-Regel wurde verworfen, weil numerische Werte in Fachlogik,
Tests und Layout-Algorithmen nicht pauschal falsch sind.

## Enforcement

`swiftlint lint --strict` prüft die Custom Rule `no_direct_font_size`. Der
Architektur-Guard verlangt für Änderungen an `.swiftlint.yml` zusätzlich einen ADR.
