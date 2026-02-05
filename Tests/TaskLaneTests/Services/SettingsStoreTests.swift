import Testing
import Foundation
@testable import TaskLane

@Suite("SettingsStore Tests")
@MainActor
struct SettingsStoreTests {

    // Create a fresh UserDefaults suite for each test
    private func createTestDefaults() -> UserDefaults {
        let suiteName = "com.tasklane.tests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    // MARK: - Load

    @Test("load returns default settings when no data exists")
    func loadDefaultSettings() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        let settings = store.load()

        #expect(settings == TaskLaneSettings())
    }

    @Test("load returns saved settings")
    func loadSavedSettings() throws {
        let defaults = createTestDefaults()

        // Manually save settings to defaults
        var customSettings = TaskLaneSettings()
        customSettings.height = 100
        customSettings.position = .top
        customSettings.showClock = false

        let data = try JSONEncoder().encode(customSettings)
        defaults.set(data, forKey: "TaskLaneSettings")

        let store = SettingsStore(defaults: defaults)
        let loaded = store.load()

        #expect(loaded.height == 100)
        #expect(loaded.position == .top)
        #expect(loaded.showClock == false)
    }

    @Test("load returns default settings on invalid data")
    func loadDefaultsOnInvalidData() {
        let defaults = createTestDefaults()
        defaults.set(Data([0, 1, 2, 3]), forKey: "TaskLaneSettings")

        let store = SettingsStore(defaults: defaults)
        let settings = store.load()

        #expect(settings == TaskLaneSettings())
    }

    // MARK: - Save

    @Test("save persists settings to defaults")
    func savePersistsSettings() throws {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        var settings = TaskLaneSettings()
        settings.height = 64
        settings.autoHide = true
        settings.pinnedAppBundleIDs = ["com.apple.Safari"]

        store.save(settings)

        // Verify by loading raw data
        let data = defaults.data(forKey: "TaskLaneSettings")
        #expect(data != nil)

        let decoded = try JSONDecoder().decode(TaskLaneSettings.self, from: data!)
        #expect(decoded.height == 64)
        #expect(decoded.autoHide == true)
        #expect(decoded.pinnedAppBundleIDs == ["com.apple.Safari"])
    }

    @Test("save followed by load returns same settings")
    func saveLoadRoundTrip() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        var settings = TaskLaneSettings()
        settings.position = .left
        settings.cornerRadius = 12
        settings.hoverDelay = 0.5

        store.save(settings)
        let loaded = store.load()

        #expect(loaded.position == .left)
        #expect(loaded.cornerRadius == 12)
        #expect(loaded.hoverDelay == 0.5)
    }

    // MARK: - Reset

    @Test("reset removes settings from defaults")
    func resetRemovesSettings() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        var settings = TaskLaneSettings()
        settings.height = 100
        store.save(settings)

        store.reset()

        #expect(defaults.data(forKey: "TaskLaneSettings") == nil)
    }

    @Test("load after reset returns defaults")
    func loadAfterResetReturnsDefaults() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        var settings = TaskLaneSettings()
        settings.height = 100
        store.save(settings)

        store.reset()
        let loaded = store.load()

        #expect(loaded == TaskLaneSettings())
    }

    // MARK: - Pinned Apps

    @Test("addPinnedApp adds bundle ID")
    func addPinnedApp() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.apple.Safari")

        let loaded = store.load()
        #expect(loaded.pinnedAppBundleIDs.contains("com.apple.Safari"))
    }

    @Test("addPinnedApp does not add duplicates")
    func addPinnedAppNoDuplicates() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.apple.Safari")
        store.addPinnedApp("com.apple.Safari")

        let loaded = store.load()
        #expect(loaded.pinnedAppBundleIDs.filter { $0 == "com.apple.Safari" }.count == 1)
    }

    @Test("removePinnedApp removes bundle ID")
    func removePinnedApp() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.apple.Safari")
        store.addPinnedApp("com.apple.mail")
        store.removePinnedApp("com.apple.Safari")

        let loaded = store.load()
        #expect(!loaded.pinnedAppBundleIDs.contains("com.apple.Safari"))
        #expect(loaded.pinnedAppBundleIDs.contains("com.apple.mail"))
    }

    @Test("removePinnedApp is no-op for non-existent ID")
    func removePinnedAppNonExistent() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("com.apple.Safari")
        store.removePinnedApp("com.apple.nonexistent")

        let loaded = store.load()
        #expect(loaded.pinnedAppBundleIDs == ["com.apple.Safari"])
    }

    // MARK: - Move Pinned App

    @Test("movePinnedApp reorders apps correctly")
    func movePinnedApp() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")
        store.addPinnedApp("app3")

        // Move app1 to position 2 (after app2)
        store.movePinnedApp(from: 0, to: 2)

        let loaded = store.load()
        #expect(loaded.pinnedAppBundleIDs == ["app2", "app1", "app3"])
    }

    @Test("movePinnedApp with invalid source does nothing")
    func movePinnedAppInvalidSource() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")

        store.movePinnedApp(from: -1, to: 1)
        store.movePinnedApp(from: 10, to: 1)

        let loaded = store.load()
        #expect(loaded.pinnedAppBundleIDs == ["app1", "app2"])
    }

    @Test("movePinnedApp with invalid destination does nothing")
    func movePinnedAppInvalidDestination() {
        let defaults = createTestDefaults()
        let store = SettingsStore(defaults: defaults)

        store.addPinnedApp("app1")
        store.addPinnedApp("app2")

        store.movePinnedApp(from: 0, to: -1)
        store.movePinnedApp(from: 0, to: 10)

        let loaded = store.load()
        #expect(loaded.pinnedAppBundleIDs == ["app1", "app2"])
    }
}
