import Foundation
import Testing
@testable import TaskLane

@Suite("SettingsStore Tests")
@MainActor
struct SettingsStoreTests {

    // MARK: - Setup

    /// Create a fresh UserDefaults for testing
    private func createTestDefaults() -> UserDefaults {
        let suiteName = "com.tasklane.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        return defaults
    }

    // MARK: - Load

    @Test("load returns default settings when none saved")
    func loadDefaultSettings() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        let settings = store.load()

        #expect(settings == TaskLaneSettings())
    }

    @Test("load returns saved settings")
    func loadSavedSettings() throws {
        let defaults = createTestDefaults()

        // Pre-save some settings
        var savedSettings = TaskLaneSettings()
        savedSettings.height = 100
        savedSettings.showClock = false

        let data = try JSONEncoder().encode(savedSettings)
        defaults.set(data, forKey: "TaskLaneSettings")

        let store = SettingsStore(defaults: defaults)
        let settings = store.load()

        #expect(settings.height == 100)
        #expect(settings.showClock == false)
    }

    // MARK: - Save

    @Test("save persists settings")
    func saveSettings() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        var settings = TaskLaneSettings()
        settings.position = .top
        settings.height = 64

        store.save(settings)

        // Verify by loading back
        let loaded = store.load()
        #expect(loaded.position == .top)
        #expect(loaded.height == 64)
    }

    // MARK: - Reset

    @Test("reset removes saved settings")
    func resetSettings() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        // Save non-default settings
        var settings = TaskLaneSettings()
        settings.height = 100
        store.save(settings)

        // Reset
        store.reset()

        // Load should return defaults
        let loaded = store.load()
        #expect(loaded.height == 48) // Default value
    }

    // MARK: - Pinned Apps

    @Test("addPinnedApp adds bundle ID")
    func addPinnedApp() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.example.app")

        let settings = store.load()
        #expect(settings.pinnedAppBundleIDs.contains("com.example.app"))
    }

    @Test("addPinnedApp does not add duplicates")
    func addPinnedAppNoDuplicate() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.example.app")
        store.addPinnedApp("com.example.app")

        let settings = store.load()
        let count = settings.pinnedAppBundleIDs.filter { $0 == "com.example.app" }.count
        #expect(count == 1)
    }

    @Test("removePinnedApp removes bundle ID")
    func removePinnedApp() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.example.app1")
        store.addPinnedApp("com.example.app2")
        store.removePinnedApp("com.example.app1")

        let settings = store.load()
        #expect(!settings.pinnedAppBundleIDs.contains("com.example.app1"))
        #expect(settings.pinnedAppBundleIDs.contains("com.example.app2"))
    }

    @Test("removePinnedApp handles non-existent bundle ID")
    func removePinnedAppNonExistent() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.example.app")

        // Should not crash
        store.removePinnedApp("com.nonexistent.app")

        let settings = store.load()
        #expect(settings.pinnedAppBundleIDs.contains("com.example.app"))
    }

    // MARK: - Move Pinned App

    @Test("movePinnedApp reorders correctly")
    func movePinnedApp() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")
        store.addPinnedApp("app3")

        store.movePinnedApp(from: 0, to: 2)

        let settings = store.load()
        #expect(settings.pinnedAppBundleIDs == ["app2", "app1", "app3"])
    }

    @Test("movePinnedApp handles move to end")
    func movePinnedAppToEnd() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")
        store.addPinnedApp("app3")

        store.movePinnedApp(from: 0, to: 3)

        let settings = store.load()
        #expect(settings.pinnedAppBundleIDs == ["app2", "app3", "app1"])
    }

    @Test("movePinnedApp handles invalid source index")
    func movePinnedAppInvalidSource() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")

        store.movePinnedApp(from: -1, to: 1)
        store.movePinnedApp(from: 10, to: 1)

        let settings = store.load()
        #expect(settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    @Test("movePinnedApp handles invalid destination index")
    func movePinnedAppInvalidDestination() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")

        store.movePinnedApp(from: 0, to: -1)
        store.movePinnedApp(from: 0, to: 10)

        let settings = store.load()
        #expect(settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    // MARK: - Corruption Handling

    @Test("load handles corrupted data gracefully")
    func loadCorruptedData() {
        let defaults = createTestDefaults()

        // Save invalid JSON data
        defaults.set(Data("not valid json".utf8), forKey: "TaskLaneSettings")

        let store = SettingsStore(defaults: defaults)
        let settings = store.load()

        // Should return default settings
        #expect(settings == TaskLaneSettings())
    }
}
