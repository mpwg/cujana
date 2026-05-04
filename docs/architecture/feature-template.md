# Feature-Template

Dieses Template beschreibt, wie ein neues Feature in Cujana angelegt wird.

## Ordner

```text
Cujana/Features/<FeatureName>/
  <FeatureName>View.swift
  <FeatureName>ViewModel.swift
  <FeatureName>UseCases.swift       # optional
  <FeatureName>Models.swift         # optional
  Components/                       # optional
```

## Minimaler Start

Für ein kleines Feature reichen oft zwei Dateien:

```text
<FeatureName>View.swift
<FeatureName>ViewModel.swift
```

Ein Use Case wird erst ergänzt, wenn echte fachliche Logik oder Wiederverwendung entsteht.

## View-Regeln

- Zeigt Zustand.
- Sendet Nutzeraktionen an das ViewModel.
- Enthält keine Netzwerk- oder Persistenzlogik.
- Enthält keine komplexe Fachlogik.

## ViewModel-Regeln

- Hält ViewState.
- Ruft Use Cases oder Repository-Protokolle auf.
- Mappt Domain-Modelle in UI-Modelle.
- Ist testbar ohne Simulator.

## Test-Regeln

Zu jedem Feature gehören Tests für:

- wichtige ViewModel-Zustandsübergänge,
- fachliche Entscheidungen,
- Fehlerfälle,
- Regressionen für gefundene Bugs.

## Namensbeispiel

Gut:

```swift
final class ProfileViewModel { }
struct LoadProfileUseCase { }
protocol ProfileRepository { }
```

Schlecht:

```swift
final class ProfileManager { }
final class DataService { }
final class CommonHelper { }
```
