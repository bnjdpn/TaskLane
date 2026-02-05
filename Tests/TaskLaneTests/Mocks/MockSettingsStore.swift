import Foundation
@testable import TaskLane

@MainActor
final class MockSettingsStore: SettingsStoreProtocol {
    // MARK: - Configurable State

    var settings: TaskLaneSettings = TaskLaneSettings()

    // MARK: - Call Tracking

    var loadCallCount = 0
    var saveCallCount = 0
    var resetCallCount = 0
    var addPinnedAppCallCount = 0
    var removePinnedAppCallCount = 0
    var movePinnedAppCallCount = 0

    var lastSavedSettings: TaskLaneSettings?
    var lastAddedPinnedApp: String?
    var lastRemovedPinnedApp: String?

    // MARK: - Protocol Implementation

    func load() -> TaskLaneSettings {
        loadCallCount += 1
        return settings
    }

    func save(_ settings: TaskLaneSettings) {
        saveCallCount += 1
        self.settings = settings
        lastSavedSettings = settings
    }

    func reset() {
        resetCallCount += 1
        settings = TaskLaneSettings()
    }

    func addPinnedApp(_ bundleID: String) {
        addPinnedAppCallCount += 1
        lastAddedPinnedApp = bundleID
        if !settings.pinnedAppBundleIDs.contains(bundleID) {
            settings.pinnedAppBundleIDs.append(bundleID)
        }
    }

    func removePinnedApp(_ bundleID: String) {
        removePinnedAppCallCount += 1
        lastRemovedPinnedApp = bundleID
        settings.pinnedAppBundleIDs.removeAll { $0 == bundleID }
    }

    func movePinnedApp(from source: Int, to destination: Int) {
        movePinnedAppCallCount += 1
        guard source >= 0, source < settings.pinnedAppBundleIDs.count,
              destination >= 0, destination <= settings.pinnedAppBundleIDs.count
        else { return }

        let item = settings.pinnedAppBundleIDs.remove(at: source)
        let adjustedDestination = destination > source ? destination - 1 : destination
        settings.pinnedAppBundleIDs.insert(item, at: adjustedDestination)
    }

    // MARK: - Test Helpers

    func resetTracking() {
        loadCallCount = 0
        saveCallCount = 0
        resetCallCount = 0
        addPinnedAppCallCount = 0
        removePinnedAppCallCount = 0
        movePinnedAppCallCount = 0
        lastSavedSettings = nil
        lastAddedPinnedApp = nil
        lastRemovedPinnedApp = nil
    }
}
