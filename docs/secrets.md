# Umgang mit lokalen Secrets

`Configuration/LocalSecrets.xcconfig` enthält lokale Build-Settings für echte
Secret-Werte. Diese Datei darf nicht in Commits, Pull Requests, Issues,
Screenshots, Logs oder Support-Ausgaben kopiert werden.

Die folgenden Werte gelten als geheim, sobald sie nicht leer sind:

- `APPLE_DEVELOPER_TEAM_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `CUJANA_SENTRY_DSN`
- `CUJANA_TELEMETRY_APP_ID`
- `POLLENINFORMATION_API_KEY`
- `MATCH_PASSWORD`
- `MATCH_GIT_BASIC_AUTHORIZATION`

Lokale Builds dürfen die Datei mit leeren Platzhaltern verwenden. Echte Werte
kommen lokal aus der eigenen Umgebung und in CI aus GitHub Actions Secrets.

Vor dem Teilen von Terminal-Ausgaben muss geprüft werden, dass keine
`LocalSecrets.xcconfig`-Inhalte, keine `xcodebuild -showBuildSettings`-Ausgaben
mit Secret-Werten und keine fastlane-Kommandos mit Secret-Build-Settings
enthalten sind. Shell-Xtrace (`set -x`) ist in Build-, Release- und CI-Skripten
nicht erlaubt, weil dadurch Build Settings mit Secret-Werten sichtbar werden
können.

`make secret-check` und `make architecture-check` blockieren versehentlich
versionierte Secret-Werte. CI führt dieselbe Prüfung für jeden Pull Request und
jeden Push auf `main` aus.
