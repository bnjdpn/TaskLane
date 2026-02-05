import Testing
import AppKit
@testable import TaskLane

@Suite("AppState Tests")
@MainActor
struct AppStateTests {

    // MARK: - Initialization

    @Test("AppState initializes with default services")
    func initWithDefaults() {
        let state = AppState()

        // Should have default settings
        #expect(state.settings == TaskLaneSettings())
        #expect(state.taskbarItems.isEmpty)
        #expect(state.activeAppBundleID == nil)
        #expect(state.windowsByApp.isEmpty)
    }

    @Test("AppState loads settings from store on init")
    func loadsSettingsOnInit() {
        let mockStore = MockSettingsStore()
        var customSettings = TaskLaneSettings()
        customSettings.height = 100
        customSettings.showClock = false
        mockStore.setSettings(customSettings)

        let state = AppState(settingsStore: mockStore)

        #expect(state.settings.height == 100)
        #expect(state.settings.showClock == false)
        #expect(mockStore.loadCallCount == 1)
    }

    @Test("AppState initializes with all mock services")
    func initWithAllMocks() {
        let mockStore = MockSettingsStore()
        let mockAppMonitor = MockAppMonitor()
        let mockWindowMonitor = MockWindowMonitor()
        let mockThumbnailProvider = MockThumbnailProvider()
        let mockPermissionManager = MockPermissionManager()

        let state = AppState(
            settingsStore: mockStore,
            appMonitor: mockAppMonitor,
            windowMonitor: mockWindowMonitor,
            thumbnailProvider: mockThumbnailProvider,
            permissionManager: mockPermissionManager
        )

        #expect(state.settings == TaskLaneSettings())
        #expect(mockStore.loadCallCount == 1)
    }

    // MARK: - Settings Persistence

    @Test("Settings changes are saved to store")
    func settingsChangesAreSaved() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.settings.height = 64

        #expect(mockStore.saveCallCount >= 1)
        #expect(mockStore.savedSettings?.height == 64)
    }

    @Test("Multiple settings changes trigger multiple saves")
    func multipleSettingsChangesTriggerMultipleSaves() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.settings.height = 64
        state.settings.showClock = false
        state.settings.autoHide = true

        #expect(mockStore.saveCallCount >= 3)
    }

    @Test("onSettingsChanged callback is called")
    func onSettingsChangedCallback() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        var callbackCalled = false
        state.onSettingsChanged = {
            callbackCalled = true
        }

        state.settings.autoHide = true

        #expect(callbackCalled == true)
    }

    @Test("onSettingsChanged callback is called for each change")
    func onSettingsChangedCallbackMultipleTimes() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        var callbackCount = 0
        state.onSettingsChanged = {
            callbackCount += 1
        }

        state.settings.height = 50
        state.settings.height = 60
        state.settings.showClock = false

        #expect(callbackCount == 3)
    }

    // MARK: - Lifecycle

    @Test("start begins monitoring and checks permissions")
    func startBeginsMonitoring() {
        let mockAppMonitor = MockAppMonitor()
        let mockPermissionManager = MockPermissionManager()

        let state = AppState(
            appMonitor: mockAppMonitor,
            permissionManager: mockPermissionManager
        )

        state.start()

        #expect(mockAppMonitor.startMonitoringCallCount == 1)
        #expect(mockPermissionManager.hasScreenRecordingCallCount >= 1)
    }

    @Test("start refreshes window list")
    func startRefreshesWindowList() {
        let mockAppMonitor = MockAppMonitor()
        let mockWindowMonitor = MockWindowMonitor()

        let state = AppState(
            appMonitor: mockAppMonitor,
            windowMonitor: mockWindowMonitor
        )

        state.start()

        #expect(mockWindowMonitor.getWindowsGroupedByAppCallCount >= 1)
    }

    @Test("stop stops monitoring")
    func stopStopsMonitoring() {
        let mockAppMonitor = MockAppMonitor()
        let state = AppState(appMonitor: mockAppMonitor)

        state.start()
        state.stop()

        #expect(mockAppMonitor.stopMonitoringCallCount == 1)
    }

    @Test("stop can be called without start")
    func stopWithoutStart() {
        let mockAppMonitor = MockAppMonitor()
        let state = AppState(appMonitor: mockAppMonitor)

        // Should not crash
        state.stop()

        #expect(mockAppMonitor.stopMonitoringCallCount == 1)
    }

    // MARK: - Permissions

    @Test("hasScreenRecordingPermission reflects permission manager state when granted")
    func permissionStateReflectedWhenGranted() {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.setScreenRecordingPermission(true)

        let state = AppState(permissionManager: mockPermissionManager)
        state.start()

        #expect(state.hasScreenRecordingPermission == true)
    }

    @Test("hasScreenRecordingPermission reflects permission manager state when denied")
    func permissionStateReflectedWhenDenied() {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.setScreenRecordingPermission(false)

        let state = AppState(permissionManager: mockPermissionManager)
        state.start()

        #expect(state.hasScreenRecordingPermission == false)
    }

    @Test("recheckPermissions updates permission state")
    func recheckPermissions() {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.setScreenRecordingPermission(false)

        let state = AppState(permissionManager: mockPermissionManager)
        state.start()

        #expect(state.hasScreenRecordingPermission == false)

        mockPermissionManager.setScreenRecordingPermission(true)
        state.recheckPermissions()

        #expect(state.hasScreenRecordingPermission == true)
    }

    @Test("recheckPermissions refreshes window list when permission granted")
    func recheckPermissionsRefreshesWindowList() {
        let mockPermissionManager = MockPermissionManager()
        let mockWindowMonitor = MockWindowMonitor()
        mockPermissionManager.setScreenRecordingPermission(false)

        let state = AppState(
            windowMonitor: mockWindowMonitor,
            permissionManager: mockPermissionManager
        )
        state.start()

        let initialCallCount = mockWindowMonitor.getWindowsGroupedByAppCallCount

        mockPermissionManager.setScreenRecordingPermission(true)
        state.recheckPermissions()

        #expect(mockWindowMonitor.getWindowsGroupedByAppCallCount > initialCallCount)
    }

    // MARK: - Pin/Unpin

    @Test("pinApp adds bundle ID to pinned list")
    func pinApp() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.pinApp("com.apple.Safari")

        #expect(state.settings.pinnedAppBundleIDs.contains("com.apple.Safari"))
    }

    @Test("pinApp does not add duplicates")
    func pinAppNoDuplicates() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.pinApp("com.apple.Safari")
        state.pinApp("com.apple.Safari")

        let count = state.settings.pinnedAppBundleIDs.filter { $0 == "com.apple.Safari" }.count
        #expect(count == 1)
    }

    @Test("pinApp preserves existing pinned apps")
    func pinAppPreservesExisting() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["com.apple.mail"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.pinApp("com.apple.Safari")

        #expect(state.settings.pinnedAppBundleIDs.contains("com.apple.mail"))
        #expect(state.settings.pinnedAppBundleIDs.contains("com.apple.Safari"))
        #expect(state.settings.pinnedAppBundleIDs.count == 2)
    }

    @Test("pinApp appends to end of list")
    func pinAppAppendsToEnd() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.pinApp("app3")

        #expect(state.settings.pinnedAppBundleIDs == ["app1", "app2", "app3"])
    }

    @Test("unpinApp removes bundle ID from pinned list")
    func unpinApp() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["com.apple.Safari", "com.apple.mail"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.unpinApp("com.apple.Safari")

        #expect(!state.settings.pinnedAppBundleIDs.contains("com.apple.Safari"))
        #expect(state.settings.pinnedAppBundleIDs.contains("com.apple.mail"))
    }

    @Test("unpinApp does nothing for non-existent app")
    func unpinAppNonExistent() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["com.apple.Safari"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.unpinApp("com.apple.mail")

        #expect(state.settings.pinnedAppBundleIDs == ["com.apple.Safari"])
    }

    @Test("unpinApp removes all occurrences")
    func unpinAppRemovesAll() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        // Simulate a corrupted state with duplicates
        settings.pinnedAppBundleIDs = ["com.apple.Safari", "com.apple.mail", "com.apple.Safari"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.unpinApp("com.apple.Safari")

        #expect(!state.settings.pinnedAppBundleIDs.contains("com.apple.Safari"))
        #expect(state.settings.pinnedAppBundleIDs == ["com.apple.mail"])
    }

    // MARK: - Move Pinned App

    @Test("movePinnedApp reorders correctly moving forward")
    func movePinnedAppForward() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2", "app3"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.movePinnedApp(from: 0, to: 2)

        #expect(state.settings.pinnedAppBundleIDs == ["app2", "app1", "app3"])
    }

    @Test("movePinnedApp reorders correctly moving backward")
    func movePinnedAppBackward() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2", "app3"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.movePinnedApp(from: 2, to: 0)

        #expect(state.settings.pinnedAppBundleIDs == ["app3", "app1", "app2"])
    }

    @Test("movePinnedApp to end of list")
    func movePinnedAppToEnd() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2", "app3"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.movePinnedApp(from: 0, to: 3)

        #expect(state.settings.pinnedAppBundleIDs == ["app2", "app3", "app1"])
    }

    @Test("movePinnedApp handles negative source index")
    func movePinnedAppNegativeSource() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)

        // Should not crash with invalid indices
        state.movePinnedApp(from: -1, to: 0)

        // List should be unchanged
        #expect(state.settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    @Test("movePinnedApp handles negative destination index")
    func movePinnedAppNegativeDestination() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)

        state.movePinnedApp(from: 0, to: -1)

        #expect(state.settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    @Test("movePinnedApp handles out of bounds source index")
    func movePinnedAppOutOfBoundsSource() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)

        state.movePinnedApp(from: 10, to: 0)

        #expect(state.settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    @Test("movePinnedApp handles out of bounds destination index")
    func movePinnedAppOutOfBoundsDestination() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)

        state.movePinnedApp(from: 0, to: 10)

        #expect(state.settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    @Test("movePinnedApp same position does not change order")
    func movePinnedAppSamePosition() {
        let mockStore = MockSettingsStore()
        var settings = TaskLaneSettings()
        settings.pinnedAppBundleIDs = ["app1", "app2", "app3"]
        mockStore.setSettings(settings)

        let state = AppState(settingsStore: mockStore)
        state.movePinnedApp(from: 1, to: 1)

        #expect(state.settings.pinnedAppBundleIDs == ["app1", "app2", "app3"])
    }

    @Test("movePinnedApp on empty list does nothing")
    func movePinnedAppEmptyList() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.movePinnedApp(from: 0, to: 1)

        #expect(state.settings.pinnedAppBundleIDs.isEmpty)
    }

    // MARK: - Window Refresh

    @Test("refreshWindowList updates windowsByApp")
    func refreshWindowListUpdatesWindows() {
        let mockWindowMonitor = MockWindowMonitor()
        let mockAppMonitor = MockAppMonitor()

        let state = AppState(
            appMonitor: mockAppMonitor,
            windowMonitor: mockWindowMonitor
        )

        // Set up mock windows
        let dict: [CFString: Any] = [
            kCGWindowNumber: CGWindowID(123),
            kCGWindowOwnerPID: pid_t(456),
            kCGWindowOwnerName: "TestApp",
            kCGWindowLayer: 0,
            kCGWindowIsOnscreen: true,
            kCGWindowBounds: ["X": CGFloat(0), "Y": CGFloat(0), "Width": CGFloat(800), "Height": CGFloat(600)]
        ]

        if let windowInfo = WindowInfo(from: dict as CFDictionary) {
            mockWindowMonitor.setWindows(["com.test.app": [windowInfo]])
        }

        state.refreshWindowList()

        #expect(mockWindowMonitor.getWindowsGroupedByAppCallCount >= 1)
        #expect(state.windowsByApp["com.test.app"]?.count == 1)
    }

    @Test("refreshWindowList clears windows when monitor returns empty")
    func refreshWindowListClearsWindows() {
        let mockWindowMonitor = MockWindowMonitor()
        let mockAppMonitor = MockAppMonitor()

        let state = AppState(
            appMonitor: mockAppMonitor,
            windowMonitor: mockWindowMonitor
        )

        // Initially set some windows
        let dict: [CFString: Any] = [
            kCGWindowNumber: CGWindowID(123),
            kCGWindowOwnerPID: pid_t(456),
            kCGWindowOwnerName: "TestApp",
            kCGWindowLayer: 0,
            kCGWindowIsOnscreen: true,
            kCGWindowBounds: ["X": CGFloat(0), "Y": CGFloat(0), "Width": CGFloat(800), "Height": CGFloat(600)]
        ]

        if let windowInfo = WindowInfo(from: dict as CFDictionary) {
            mockWindowMonitor.setWindows(["com.test.app": [windowInfo]])
        }
        state.refreshWindowList()

        // Now clear windows
        mockWindowMonitor.setWindows([:])
        state.refreshWindowList()

        #expect(state.windowsByApp.isEmpty)
    }

    // MARK: - App Activation Callback

    @Test("App activation updates activeAppBundleID")
    func appActivationUpdatesActiveApp() {
        let mockAppMonitor = MockAppMonitor()
        let state = AppState(appMonitor: mockAppMonitor)

        // Trigger callback setup by starting
        state.start()

        // Simulate app activation
        mockAppMonitor.simulateAppActivated("com.apple.Safari")

        #expect(state.activeAppBundleID == "com.apple.Safari")
    }

    @Test("App activation with nil clears activeAppBundleID")
    func appActivationNilClearsActiveApp() {
        let mockAppMonitor = MockAppMonitor()
        let state = AppState(appMonitor: mockAppMonitor)

        state.start()
        mockAppMonitor.simulateAppActivated("com.apple.Safari")
        mockAppMonitor.simulateAppActivated(nil)

        #expect(state.activeAppBundleID == nil)
    }

    @Test("Multiple app activations update correctly")
    func multipleAppActivations() {
        let mockAppMonitor = MockAppMonitor()
        let state = AppState(appMonitor: mockAppMonitor)

        state.start()

        mockAppMonitor.simulateAppActivated("com.apple.Safari")
        #expect(state.activeAppBundleID == "com.apple.Safari")

        mockAppMonitor.simulateAppActivated("com.apple.mail")
        #expect(state.activeAppBundleID == "com.apple.mail")

        mockAppMonitor.simulateAppActivated("com.apple.Finder")
        #expect(state.activeAppBundleID == "com.apple.Finder")
    }

    // MARK: - Thumbnail Requests

    @Test("requestThumbnail returns nil without permission")
    func thumbnailWithoutPermission() async {
        let mockPermissionManager = MockPermissionManager()
        let mockThumbnailProvider = MockThumbnailProvider()
        mockPermissionManager.setScreenRecordingPermission(false)

        let state = AppState(
            thumbnailProvider: mockThumbnailProvider,
            permissionManager: mockPermissionManager
        )
        state.start()

        let result = await state.requestThumbnail(for: CGWindowID(123))

        #expect(result == nil)
    }

    @Test("requestThumbnail calls provider with permission")
    func thumbnailWithPermission() async {
        let mockPermissionManager = MockPermissionManager()
        let mockThumbnailProvider = MockThumbnailProvider()
        mockPermissionManager.setScreenRecordingPermission(true)

        let state = AppState(
            thumbnailProvider: mockThumbnailProvider,
            permissionManager: mockPermissionManager
        )
        state.start()

        _ = await state.requestThumbnail(for: CGWindowID(123))

        let captureCount = await mockThumbnailProvider.captureCallCount
        #expect(captureCount == 1)
    }

    // MARK: - Settings Variations

    @Test("Settings position change is persisted")
    func settingsPositionChange() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.settings.position = .top

        #expect(mockStore.savedSettings?.position == .top)
    }

    @Test("Settings appearance mode change is persisted")
    func settingsAppearanceModeChange() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.settings.appearanceMode = .dark

        #expect(mockStore.savedSettings?.appearanceMode == .dark)
    }

    @Test("Settings pinned apps change triggers save")
    func settingsPinnedAppsChange() {
        let mockStore = MockSettingsStore()
        let state = AppState(settingsStore: mockStore)

        state.settings.pinnedAppBundleIDs = ["com.apple.Safari", "com.apple.mail"]

        #expect(mockStore.savedSettings?.pinnedAppBundleIDs == ["com.apple.Safari", "com.apple.mail"])
    }
}
