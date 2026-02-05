# Test Infrastructure & Open-Source Quality Setup

**Date**: 2026-02-05
**Status**: Approved

## Objectif

Mettre en place une infrastructure de tests complète (80%+ couverture) et des outils de qualité CI/CD pour gérer TaskLane comme un projet open-source professionnel.

## Décisions

| Question | Choix |
|----------|-------|
| Niveau de couverture | Complet (~80%+) |
| Gestion des APIs système | Protocoles + Injection de dépendances |
| Tests UI SwiftUI | ViewInspector |
| Checks CI | Complet (seuil couverture, SwiftLint, badges, Dependabot) |
| Stratégie de push | Tout préparer localement, puis push |

---

## Architecture

### Nouveaux Protocoles (`TaskLane/Protocols/`)

```swift
protocol WindowMonitorProtocol {
    func getWindows() -> [WindowInfo]
    func startMonitoring()
    func stopMonitoring()
}

protocol AppMonitorProtocol {
    func getRunningApps() -> [NSRunningApplication]
    func startMonitoring()
    func stopMonitoring()
}

protocol ThumbnailProviderProtocol {
    func captureThumbnail(windowID: CGWindowID) async -> NSImage?
}

protocol WindowControllerProtocol {
    func focus(window: WindowInfo)
    func quit(app: NSRunningApplication)
    func minimize(window: WindowInfo)
}

protocol PermissionManagerProtocol {
    func checkScreenRecording() -> Bool
    func checkAccessibility() -> Bool
    func requestScreenRecording()
    func requestAccessibility()
}

protocol SettingsStoreProtocol {
    func load() -> Settings
    func save(_ settings: Settings)
}
```

### Injection dans AppState

```swift
@Observable
final class AppState {
    private let windowMonitor: WindowMonitorProtocol
    private let appMonitor: AppMonitorProtocol
    private let thumbnailProvider: ThumbnailProviderProtocol
    private let windowController: WindowControllerProtocol
    private let permissionManager: PermissionManagerProtocol
    private let settingsStore: SettingsStoreProtocol

    init(
        windowMonitor: WindowMonitorProtocol = WindowMonitor(),
        appMonitor: AppMonitorProtocol = AppMonitor(),
        thumbnailProvider: ThumbnailProviderProtocol = ThumbnailProvider(),
        windowController: WindowControllerProtocol = WindowController(),
        permissionManager: PermissionManagerProtocol = PermissionManager(),
        settingsStore: SettingsStoreProtocol = SettingsStore()
    ) {
        self.windowMonitor = windowMonitor
        self.appMonitor = appMonitor
        self.thumbnailProvider = thumbnailProvider
        self.windowController = windowController
        self.permissionManager = permissionManager
        self.settingsStore = settingsStore
    }
}
```

---

## Structure des Tests

```
Tests/
└── TaskLaneTests/
    ├── Mocks/
    │   ├── MockWindowMonitor.swift
    │   ├── MockAppMonitor.swift
    │   ├── MockThumbnailProvider.swift
    │   ├── MockWindowController.swift
    │   ├── MockPermissionManager.swift
    │   └── MockSettingsStore.swift
    │
    ├── Models/
    │   ├── SettingsTests.swift
    │   ├── TaskbarItemTests.swift
    │   └── WindowInfoTests.swift
    │
    ├── Services/
    │   ├── AppStateTests.swift
    │   └── SettingsStoreTests.swift
    │
    └── Views/
        ├── TaskbarViewTests.swift
        ├── AppButtonViewTests.swift
        ├── WindowListPopoverTests.swift
        ├── ClockViewTests.swift
        └── Settings/
            ├── SettingsViewTests.swift
            └── AppearanceSettingsViewTests.swift
```

### Couverture Cible

| Catégorie | Objectif |
|-----------|----------|
| Models | 95%+ |
| Services/AppState | 85%+ |
| Views | 70%+ |
| **Global** | **80%+** |

---

## CI/CD

### Workflow `build.yml` (mis à jour)

```yaml
name: Build

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-14

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable

      - name: Install SwiftLint
        run: brew install swiftlint

      - name: SwiftLint
        run: swiftlint lint --strict

      - name: Build
        run: swift build -c release

      - name: Run Tests with Coverage
        run: swift test --enable-code-coverage

      - name: Generate Coverage Report
        run: |
          BIN_PATH=$(swift build --show-bin-path)
          XCTEST_PATH=$(find .build -name "TaskLanePackageTests.xctest" -type d | head -1)
          COV_BIN="$XCTEST_PATH/Contents/MacOS/TaskLanePackageTests"
          PROF_DATA=$(find .build -name "default.profdata" -type f | head -1)
          xcrun llvm-cov export "$COV_BIN" \
            -instr-profile="$PROF_DATA" \
            -format=lcov \
            -ignore-filename-regex=".build|Tests" \
            > coverage.lcov

      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: coverage.lcov
          fail_ci_if_error: true
        env:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

      - name: Upload Build Artifact
        uses: actions/upload-artifact@v4
        with:
          name: TaskLane-build
          path: .build/release/TaskLane
          retention-days: 7
```

### Nouveaux Fichiers de Config

#### `.swiftlint.yml`

```yaml
disabled_rules:
  - line_length
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - force_unwrapping

excluded:
  - .build
  - Tests

warning_threshold: 5
```

#### `.codecov.yml`

```yaml
coverage:
  status:
    project:
      default:
        target: 80%
        threshold: 2%
    patch:
      default:
        target: 80%
```

#### `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "swift"
    directory: "/"
    schedule:
      interval: "weekly"
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## Dépendances

### Package.swift (mise à jour)

```swift
// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TaskLane",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "TaskLane", targets: ["TaskLane"])
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.0")
    ],
    targets: [
        .executableTarget(
            name: "TaskLane",
            path: "TaskLane",
            resources: [
                .process("Resources"),
                .process("Localization")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "TaskLaneTests",
            dependencies: [
                "TaskLane",
                "ViewInspector"
            ],
            path: "Tests/TaskLaneTests"
        )
    ]
)
```

---

## Plan d'Implémentation

### Phase 1 - Infrastructure
1. Créer `Tests/TaskLaneTests/` et mettre à jour `Package.swift`
2. Ajouter ViewInspector comme dépendance
3. Créer `.swiftlint.yml`
4. Vérifier que `swift test` passe

### Phase 2 - Protocoles et Mocks
5. Créer les 6 protocoles dans `TaskLane/Protocols/`
6. Adapter les services pour implémenter les protocoles
7. Modifier `AppState` pour l'injection de dépendances
8. Créer les 6 mocks

### Phase 3 - Tests
9. Tests des modèles
10. Tests de `AppState`
11. Tests des vues avec ViewInspector

### Phase 4 - CI/CD
12. Mettre à jour `build.yml`
13. Créer `.codecov.yml` et `.github/dependabot.yml`
14. Ajouter badges au `README.md`

### Phase 5 - Push
15. Commit et push sur `main`
