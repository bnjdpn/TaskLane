# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build release binary
swift build -c release

# Run the application
swift run

# Run tests
swift test

# Lint (required before push - CI runs with --strict)
swiftlint lint --strict

# Build with Xcode (CI uses this)
xcodebuild build
```

## Project Overview

TaskLane is a Windows 11-style taskbar application for macOS, built with SwiftUI. It provides window management, app launching, and window previews through a customizable taskbar panel.

**Platform**: macOS 15+ (Sequoia)
**Swift**: 6.0 toolchain with `.swiftLanguageMode(.v5)` (strict concurrency not fully adopted yet)
**License**: MIT

## Architecture

### State Management

Single source of truth via `AppState` (Swift Observable macro):
- `settings`: Persisted configuration (44+ options)
- `taskbarItems`: Derived from running apps + pinned apps
- `windowsByApp`: Grouped window data by app bundle ID

### Service Layer (`TaskLane/Services/`)

| Service | Responsibility |
|---------|----------------|
| `AppMonitor` | Tracks running apps via NSWorkspace notifications |
| `WindowMonitor` | Retrieves window info via CGWindowList APIs |
| `ThumbnailProvider` | Captures window preview screenshots |
| `PermissionManager` | Handles Screen Recording & Accessibility permissions |
| `SettingsStore` | Persists settings to UserDefaults |
| `WindowController` | Focuses/activates/quits windows |

### UI Layer (`TaskLane/Taskbar/`)

```
TaskbarView (main container)
├── AppButtonView[] (app icons with running indicators)
├── WindowListPopover (hover preview with thumbnails)
├── ClockView (system tray clock)
└── TaskbarPanel/Controller (NSPanel window management)
```

### Concurrency Model

- **MainActor isolation**: All UI state changes
- **Async/await**: Permission checks, thumbnail capture
- **Debouncing**: 200ms delay on app change notifications to reduce churn
- **Sendable types**: Thread-safe data structures for window info

## Key Files

- `Package.swift`: SPM config (Swift 6.0 tools, Swift 5 language mode)
- `Info.plist`: LSUIElement=true (menu bar accessory app), permission descriptions
- `TaskLane.entitlements`: No sandbox (required for Accessibility/Screen Recording APIs)
- `TaskLane/Models/Settings.swift`: All configuration options (position, size, colors, behavior)
- `.swiftlint.yml`: Linter config (CI uses `--strict`)

## Permissions Required

1. **Screen Recording**: Window names and preview thumbnails
2. **Accessibility**: Window focus/quit operations

Without these permissions, the app has limited functionality (no window names, no previews).

## Localization

Supported languages: English, French
Strings file: `TaskLane/Localization/Localizable.xcstrings`

## Testing

Tests are in `Tests/TaskLaneTests/`. Only model tests run in CI - service tests crash due to missing screen/accessibility access.

```bash
swift test                        # Run all tests locally
swift test --enable-code-coverage # With coverage (CI uses this)
```

## Gotchas

- **CI crashes with @MainActor tests**: Tests using `@MainActor` + Swift Testing cause SIGSEGV in GitHub Actions. Keep only model tests for CI.
- **NSImage not Sendable**: Don't use `async let` with methods returning `NSImage?` - causes Swift 6 concurrency errors.
- **Permission dialogs**: Never auto-call `requestAccessibilityPermission()` - triggers dialogs during builds/tests. Only request on explicit user action.
- **SwiftLint trailing closures**: Use explicit `action:` and `label:` parameters for `Button`, not trailing closure syntax.
