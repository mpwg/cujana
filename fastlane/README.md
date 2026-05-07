fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

Install the pinned fastlane version through Bundler:

```sh
bundle install
```

# Available Actions

## iOS

### ios sync_screenshots

```sh
bundle exec fastlane ios sync_screenshots
```

Erzeugt App-Store-Screenshots für iPhone und iPad.

### ios validate_screenshot_seed

```sh
bundle exec fastlane ios validate_screenshot_seed
```

Validiert den Screenshot-Seed ohne vollständige Screenshot-Erzeugung.

### ios upload_screenshots

```sh
bundle exec fastlane ios upload_screenshots
```

Lädt vorhandene iPhone- und iPad-Screenshots nach App Store Connect hoch.

### ios beta

```sh
bundle exec fastlane ios beta changelog:"Kurzer Changelog"
```

Baut eine Distribution-IPA mit match und lädt sie nach TestFlight hoch.

### ios verify_release

```sh
bundle exec fastlane ios verify_release version:1.0.0
```

Validiert Version, Metadaten und Screenshots für einen App-Store-Release.

### ios ensure_version_not_released

```sh
bundle exec fastlane ios ensure_version_not_released version:1.0.0
```

Prüft, dass eine Version in App Store Connect noch nicht existiert.

### ios release

```sh
bundle exec fastlane ios release version:1.0.0
```

Baut eine Distribution-IPA und lädt sie mit Metadaten und Screenshots für die manuelle App-Store-Einreichung hoch.

### ios release_testflight

```sh
bundle exec fastlane ios release_testflight changelog:"Kurzer Changelog"
```

Kompatibilitätsalias für ältere lokale Aufrufe: bitte `ios beta` verwenden.

### ios release_app_store

```sh
bundle exec fastlane ios release_app_store version:1.0.0
```

Kompatibilitätsalias für ältere lokale Aufrufe: bitte `ios release` verwenden.
