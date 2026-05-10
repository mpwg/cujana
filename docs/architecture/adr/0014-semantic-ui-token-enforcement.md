# ADR-0014: Semantische UI-Tokens werden enforced

Status: Akzeptiert  
Datum: 2026-05-10

## Kontext

Feature-Views enthielten feste numerische UI-Werte für Größen, Opacity, Animationen
und adaptive Grid-Breiten. Solche Werte erschweren konsistente Gestaltung, weil sie
nicht über die bestehenden Design- und Component-Tokens sichtbar werden.

## Entscheidung

SwiftLint erhält zusätzliche Custom Rules, die feste `frame`-Größen, adaptive
Grid-Minima, Opacity-Werte, Scale-Effekte und Animationsdauern außerhalb des
DesignSystems verbieten. Zulässige Werte werden als semantische Tokens in
`ComponentTokens.swift` gepflegt.

## Konsequenzen

Feature-Code bleibt näher an der Designsprache und neue UI-Konstanten bekommen einen
sprechenden Namen. Änderungen an visuellen Parametern laufen dadurch über zentrale
Tokens.

Die Regeln sind bewusst regex-basiert und decken die häufigsten SwiftUI-Muster ab. Für
neue Patterns müssen die Regeln bei Bedarf erweitert werden.

## Alternativen

Nur Code Review wurde verworfen, weil Magic Numbers leicht übersehen werden.

Eine vollständig generische Magic-Number-Regel wurde verworfen, weil Fachlogik und
Tests legitime numerische Werte enthalten.

## Enforcement

`swiftlint lint --strict` prüft die neuen Regeln lokal und in CI. Änderungen an
`.swiftlint.yml` bleiben durch `make architecture-check` ADR-pflichtig.
