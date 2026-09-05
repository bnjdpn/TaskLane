// Off-screen rendering of the real released TaskbarView with demonstration data.
// No monitoring is started, no permissions are requested, no user defaults are used.
import AppKit
import SwiftUI

@MainActor final class DemoSettingsStore: SettingsStoreProtocol {
    var value = TaskLaneSettings()
    func load() -> TaskLaneSettings { value }
    func save(_ settings: TaskLaneSettings) { value = settings }
    func reset() { value = TaskLaneSettings() }
    func addPinnedApp(_ bundleID: String) {}
    func removePinnedApp(_ bundleID: String) {}
    func movePinnedApp(from source: Int, to destination: Int) {}
}

@main struct CaptureSite {
    @MainActor static func main() throws {
        let destination = CommandLine.arguments[1]
        let state = AppState(settingsStore: DemoSettingsStore())
        state.settings.useBlurEffect = false
        state.settings.showClock = false
        state.settings.centerIcons = false
        state.settings.height = 56
        let demoApps = [("com.apple.finder", "Finder"), ("com.apple.Safari", "Safari"), ("com.apple.mail", "Mail"), ("com.apple.Notes", "Notes"), ("com.apple.TextEdit", "TextEdit")]
        state.taskbarItems = demoApps.enumerated().map { index, app in
            let icon = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.0).map { NSWorkspace.shared.icon(forFile: $0.path) } ?? NSImage(systemSymbolName: "app", accessibilityDescription: nil)!
            return TaskbarItem(bundleIdentifier: app.0, displayName: app.1, icon: icon, isPinned: index < 4, isRunning: index != 3, windowCount: index == 1 ? 2 : 1)
        }
        state.activeAppBundleID = "com.apple.Safari"
        for (name, scheme) in [("dark", ColorScheme.dark), ("light", ColorScheme.light)] {
            let view = TaskbarView().environment(state).environment(\.colorScheme, scheme).frame(width: 960, height: 56)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 2
            guard let cg = renderer.cgImage else { fatalError("Native view rendering failed") }
            let bitmap = NSBitmapImageRep(cgImage: cg)
            let png = bitmap.representation(using: .png, properties: [:])!
            try png.write(to: URL(fileURLWithPath: destination).appendingPathComponent("taskbar-\(name).png"))
        }
        print("Rendered the real TaskbarView with five demo apps. No desktop capture or monitoring.")
    }
}
