import Foundation
import AppKit
@testable import TaskLane

// MARK: - Mock Settings Store

@MainActor
final class MockSettingsStore: SettingsStoreProtocol {
    var savedSettings: TaskLaneSettings?
    var loadCallCount = 0
    var saveCallCount = 0
    var resetCallCount = 0

    private var settings = TaskLaneSettings()

    func load() -> TaskLaneSettings {
        loadCallCount += 1
        return settings
    }

    func save(_ settings: TaskLaneSettings) {
        saveCallCount += 1
        self.settings = settings
        savedSettings = settings
    }

    func reset() {
        resetCallCount += 1
        settings = TaskLaneSettings()
    }

    func addPinnedApp(_ bundleID: String) {
        if !settings.pinnedAppBundleIDs.contains(bundleID) {
            settings.pinnedAppBundleIDs.append(bundleID)
            save(settings)
        }
    }

    func removePinnedApp(_ bundleID: String) {
        settings.pinnedAppBundleIDs.removeAll { $0 == bundleID }
        save(settings)
    }

    func movePinnedApp(from source: Int, to destination: Int) {
        guard source >= 0, source < settings.pinnedAppBundleIDs.count,
              destination >= 0, destination <= settings.pinnedAppBundleIDs.count
        else { return }

        let item = settings.pinnedAppBundleIDs.remove(at: source)
        let adjustedDestination = destination > source ? destination - 1 : destination
        settings.pinnedAppBundleIDs.insert(item, at: adjustedDestination)
        save(settings)
    }

    // Test helper
    func setSettings(_ settings: TaskLaneSettings) {
        self.settings = settings
    }
}

// MARK: - Mock App Monitor

@MainActor
final class MockAppMonitor: AppMonitorProtocol {
    var onAppsChanged: (([NSRunningApplication]) -> Void)?
    var onAppActivated: ((String?) -> Void)?

    var isMonitoring = false
    var startMonitoringCallCount = 0
    var stopMonitoringCallCount = 0
    var refreshAppsCallCount = 0

    private var mockRunningApps: [NSRunningApplication] = []

    func startMonitoring() {
        startMonitoringCallCount += 1
        isMonitoring = true
    }

    func stopMonitoring() {
        stopMonitoringCallCount += 1
        isMonitoring = false
    }

    func refreshApps() {
        refreshAppsCallCount += 1
        onAppsChanged?(mockRunningApps)
    }

    func getRunningApps() -> [NSRunningApplication] {
        return mockRunningApps
    }

    // Test helpers
    func simulateAppsChanged(_ apps: [NSRunningApplication]) {
        mockRunningApps = apps
        onAppsChanged?(apps)
    }

    func simulateAppActivated(_ bundleID: String?) {
        onAppActivated?(bundleID)
    }
}

// MARK: - Mock Window Monitor

@MainActor
final class MockWindowMonitor: WindowMonitorProtocol {
    var windowsByApp: [String: [WindowInfo]] = [:]
    var getWindowsGroupedByAppCallCount = 0

    func getWindowsGroupedByApp() -> [String: [WindowInfo]] {
        getWindowsGroupedByAppCallCount += 1
        return windowsByApp
    }

    func getWindows(for bundleID: String) -> [WindowInfo] {
        return windowsByApp[bundleID] ?? []
    }

    func getWindowCount(for bundleID: String) -> Int {
        return getWindows(for: bundleID).count
    }

    func getAllWindows() -> [WindowInfo] {
        return windowsByApp.values.flatMap { $0 }
    }

    // Test helper
    func setWindows(_ windows: [String: [WindowInfo]]) {
        windowsByApp = windows
    }
}

// MARK: - Mock Thumbnail Provider

actor MockThumbnailProvider: ThumbnailProviderProtocol {
    var captureCallCount = 0
    var clearCacheCallCount = 0
    var invalidateCallCount = 0
    var mockImage: NSImage?

    func capture(windowID: CGWindowID) async -> NSImage? {
        captureCallCount += 1
        return mockImage
    }

    func clearCache() async {
        clearCacheCallCount += 1
    }

    func invalidate(windowID: CGWindowID) async {
        invalidateCallCount += 1
    }

    // Test helper
    func setMockImage(_ image: NSImage?) {
        mockImage = image
    }
}

// MARK: - Mock Permission Manager

@MainActor
final class MockPermissionManager: PermissionManagerProtocol {
    var screenRecordingPermission = false
    var accessibilityPermission = false
    var hasScreenRecordingCallCount = 0
    var requestScreenRecordingCallCount = 0
    var hasAccessibilityCallCount = 0
    var requestAccessibilityCallCount = 0

    func hasScreenRecording() -> Bool {
        hasScreenRecordingCallCount += 1
        return screenRecordingPermission
    }

    func requestScreenRecording() {
        requestScreenRecordingCallCount += 1
    }

    func openScreenRecordingSettings() {
        // No-op for tests
    }

    func hasAccessibilityPermission() -> Bool {
        hasAccessibilityCallCount += 1
        return accessibilityPermission
    }

    func requestAccessibilityPermission() {
        requestAccessibilityCallCount += 1
    }

    // Test helpers
    func setScreenRecordingPermission(_ granted: Bool) {
        screenRecordingPermission = granted
    }

    func setAccessibilityPermission(_ granted: Bool) {
        accessibilityPermission = granted
    }
}
