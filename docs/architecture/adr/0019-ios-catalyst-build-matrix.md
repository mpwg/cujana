# ADR-0019: iOS-Produktmatrix mit Mac Catalyst

Status: Akzeptiert  
Datum: 2026-05-11

## Kontext

Die Architektur beschreibt Cujana als iOS-fokussierte App. Das Xcode-Projekt baute
aber zusätzlich native `macosx`-, `xros`- und `xrsimulator`-Oberflächen und ließ
Test-Targets auf Swift 5.0 stehen. Gleichzeitig existierten Swift-6-Guardrails in
`Configuration/Architecture.xcconfig`, waren aber nicht als gemeinsame Base
Configuration verdrahtet.

## Entscheidung

Cujana unterstützt iPhone und iPad als primäre Gerätefamilien. Mac Catalyst bleibt
ausdrücklich Teil der Build-Matrix, weil es die iPad-App auf macOS verfügbar macht
und lokale Builds sowie Tests beschleunigt.

Native macOS-Targets, visionOS und xros-Simulator-Builds gehören nicht zur
unterstützten Produktmatrix. `Designed for iPhone/iPad on Mac` und `Designed for
iPhone/iPad on Vision Pro` werden deaktiviert, damit neben Mac Catalyst keine
zusätzliche Produktoberfläche entsteht.

Alle App- und Test-Targets verwenden `Configuration/TargetDefaults.xcconfig` als Base
Configuration. Diese inkludiert die Architektur-Guardrails und optional lokale Secrets.
Test-Targets bauen mit Swift 6 und denselben Warnings-as-errors- und
Concurrency-Regeln wie das App-Target. C/ObjC-Warnungen werden ebenfalls als Fehler
behandelt. Release-App-Builds aktivieren Xcodes Produktvalidierung.

## Konsequenzen

`xcodebuild -showBuildSettings` muss für App- und Test-Targets `SWIFT_VERSION = 6.0`,
strikte Concurrency und Warnings-as-errors zeigen. Die Projektdatei beschränkt
`SUPPORTED_PLATFORMS` auf `iphoneos iphonesimulator`; Mac Catalyst wird über
`SUPPORTS_MACCATALYST = YES` aktiviert. Wenn Xcode für Catalyst-Destinationen in den
effektiven Build Settings `macosx` ergänzt, ist das SDK-bedingt und keine Freigabe für
ein natives macOS-Target.

Build- und CI-Kommandos sollen Mac Catalyst bevorzugen, sofern keine
iPhone-/iPad-spezifische Simulatorprüfung erforderlich ist.

## Alternativen

Eine rein mobile iPhone-/iPad-Matrix ohne Catalyst wurde verworfen, weil lokale Tests
dadurch langsamer und abhängiger vom iOS-Simulator würden.

visionOS wurde verworfen, weil dafür keine Produktentscheidung, UX-Strategie oder
Testabdeckung existiert.
