# ADR-0010: iCloud-Environment beim Release-Export setzen

Status: Akzeptiert
Datum: 2026-05-10

## Kontext

Der TestFlight-Upload kann von App Store Connect abgelehnt werden, wenn die signierte IPA das Entitlement `com.apple.developer.icloud-container-environment` mit leerem Wert enthält. Für App-Store- und TestFlight-Distributionen erwartet Apple den Wert `Production`.

## Entscheidung

Fastlane setzt beim `build_app`-Export für App-Store-IPAs explizit `iCloudContainerEnvironment: "Production"`.

Das App-Entitlements-Plist enthält `com.apple.developer.icloud-container-environment` als Build-Setting-Platzhalter. Debug-Builds setzen `ICLOUD_CONTAINER_ENVIRONMENT = Development`, Release-Builds setzen `ICLOUD_CONTAINER_ENVIRONMENT = Production`.

Das App-Target verwendet das Entitlements-Plist explizit über `CODE_SIGN_ENTITLEMENTS`. Nicht benötigte Push-Entitlements bleiben aus diesem Plist entfernt, damit Distribution-Builds keine ungültigen oder doppelten Push-Schlüssel signieren.

Die bestehende IPA-Entitlements-Validierung prüft zusätzlich, dass `com.apple.developer.icloud-container-environment` nicht leer oder auf einen anderen Wert gesetzt ist. Dadurch schlägt der Release-Lauf vor dem Upload fehl, falls der Export wieder ein ungültiges Entitlement erzeugt.

## Konsequenzen

TestFlight- und App-Store-Uploads verwenden ein gültiges Production-iCloud-Environment.

Die Prüfung bleibt im Release-Prozess lokalisiert und verändert keine Domain-, Feature- oder Infrastruktur-Schicht.

## Alternativen

Das Entitlement nur im Xcode-Projekt zu setzen wurde verworfen, weil der Fehler beim IPA-Export entsteht und Release-Exporte explizit die App-Store-Umgebung brauchen.
