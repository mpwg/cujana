# ADR-0024: Ungenutzte iCloud-Entitlements aus Release-Builds entfernen

Status: Akzeptiert
Datum: 2026-05-10

## Kontext

Der TestFlight-Upload kann von App Store Connect abgelehnt werden, wenn die signierte IPA das Entitlement `com.apple.developer.icloud-container-environment` mit leerem Wert enthält. Wird dieses Entitlement explizit gesetzt, muss auch das verwendete App-Store-Provisioning-Profil diese iCloud-Capability enthalten.

Cujana nutzt aktuell keine CloudKit-API im App-Code. Das Entitlements-Plist enthielt iCloud/CloudKit-Schlüssel mit leerer Containerliste.

## Entscheidung

Die ungenutzten iCloud/CloudKit-Entitlements werden aus dem App-Entitlements-Plist entfernt. Das App-Target verwendet das Entitlements-Plist explizit über `CODE_SIGN_ENTITLEMENTS`; dort bleiben nur tatsächlich benötigte Capabilities.

Nicht benötigte Push-Entitlements bleiben ebenfalls aus diesem Plist entfernt, damit Distribution-Builds keine ungültigen oder doppelten Push-Schlüssel signieren.

Die bestehende IPA-Entitlements-Validierung prüft zusätzlich, dass `com.apple.developer.icloud-container-environment` nicht leer oder auf einen anderen Wert gesetzt ist. Dadurch schlägt der Release-Lauf vor dem Upload fehl, falls der Export wieder ein ungültiges Entitlement erzeugt.

## Konsequenzen

TestFlight- und App-Store-Uploads enthalten kein iCloud-Environment-Entitlement, solange die App keine iCloud-Capability benötigt.

Die Prüfung bleibt im Release-Prozess lokalisiert und verändert keine Domain-, Feature- oder Infrastruktur-Schicht.

## Alternativen

Das Entitlement auf `Production` zu setzen wurde verworfen, weil das App-Store-Provisioning-Profil die iCloud-Capability nicht enthält und die App aktuell keine CloudKit-Funktion benötigt.
