import AppKit
import Testing
@testable import TaskLane

@Suite("AppState Tests")
@MainActor
struct AppStateTests {

    // MARK: - Initialization

    @Test("AppState initializes with default services")
    func initializationDefault() {
        let appState = AppState()

        #expect(appState.taskbarItems.isEmpty)
        #expect(appState.activeAppBundleID == nil)
        #expect(appState.windowsByApp.isEmpty)
    }

    @Test("AppState initializes with injected services")
    func initializationInjected() {
        let mockSettingsStore = MockSettingsStore()
        mockSettingsStore.settings.pinnedAppBundleIDs = ["com.apple.Safari"]

        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        #expect(appState.settings.pinnedAppBundleIDs == ["com.apple.Safari"])
        #expect(mockSettingsStore.loadCallCount == 1)
    }

    // MARK: - Settings Persistence

    @Test("Settings changes are saved")
    func settingsSaved() {
        let mockSettingsStore = MockSettingsStore()
        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.settings.height = 100

        #expect(mockSettingsStore.saveCallCount >= 1)
        #expect(mockSettingsStore.lastSavedSettings?.height == 100)
    }

    // MARK: - Lifecycle

    @Test("start() begins monitoring")
    func startMonitoring() {
        let mockAppMonitor = MockAppMonitor()
        let mockPermissionManager = MockPermissionManager()

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: mockAppMonitor,
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: mockPermissionManager
        )

        appState.start()

        #expect(mockAppMonitor.startMonitoringCallCount == 1)
        #expect(mockPermissionManager.hasScreenRecordingCallCount >= 1)
    }

    @Test("stop() stops monitoring")
    func stopMonitoring() {
        let mockAppMonitor = MockAppMonitor()

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: mockAppMonitor,
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.start()
        appState.stop()

        #expect(mockAppMonitor.stopMonitoringCallCount == 1)
    }

    // MARK: - Permissions

    @Test("Permissions are checked on start")
    func permissionsCheckedOnStart() {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.screenRecordingPermission = true

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: mockPermissionManager
        )

        appState.start()

        #expect(appState.hasScreenRecordingPermission == true)
    }

    @Test("recheckPermissions updates permission state")
    func recheckPermissions() {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.screenRecordingPermission = false

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: mockPermissionManager
        )

        appState.start()
        #expect(appState.hasScreenRecordingPermission == false)

        mockPermissionManager.screenRecordingPermission = true
        appState.recheckPermissions()

        #expect(appState.hasScreenRecordingPermission == true)
    }

    // MARK: - Window List

    // Test disabled - WindowInfoTestHelper causes crash on CI
    // @Test("refreshWindowList updates windowsByApp")
    // func refreshWindowList() { ... }

    // MARK: - Pin/Unpin

    @Test("pinApp adds bundle ID to pinned apps")
    func pinApp() {
        let mockSettingsStore = MockSettingsStore()
        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.pinApp("com.example.app")

        #expect(appState.settings.pinnedAppBundleIDs.contains("com.example.app"))
    }

    @Test("pinApp does not duplicate bundle IDs")
    func pinAppNoDuplicate() {
        let mockSettingsStore = MockSettingsStore()
        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.pinApp("com.example.app")
        appState.pinApp("com.example.app")

        let count = appState.settings.pinnedAppBundleIDs.filter { $0 == "com.example.app" }.count
        #expect(count == 1)
    }

    @Test("unpinApp removes bundle ID from pinned apps")
    func unpinApp() {
        let mockSettingsStore = MockSettingsStore()
        mockSettingsStore.settings.pinnedAppBundleIDs = ["com.example.app"]

        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.unpinApp("com.example.app")

        #expect(!appState.settings.pinnedAppBundleIDs.contains("com.example.app"))
    }

    // MARK: - Move Pinned App

    @Test("movePinnedApp reorders pinned apps")
    func movePinnedApp() {
        let mockSettingsStore = MockSettingsStore()
        mockSettingsStore.settings.pinnedAppBundleIDs = ["app1", "app2", "app3"]

        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.movePinnedApp(from: 0, to: 2)

        #expect(appState.settings.pinnedAppBundleIDs == ["app2", "app1", "app3"])
    }

    @Test("movePinnedApp handles invalid indices gracefully")
    func movePinnedAppInvalidIndices() {
        let mockSettingsStore = MockSettingsStore()
        mockSettingsStore.settings.pinnedAppBundleIDs = ["app1", "app2"]

        let appState = AppState(
            settingsStore: mockSettingsStore,
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        // Invalid source index
        appState.movePinnedApp(from: -1, to: 1)
        #expect(appState.settings.pinnedAppBundleIDs == ["app1", "app2"])

        // Invalid destination index
        appState.movePinnedApp(from: 0, to: 10)
        #expect(appState.settings.pinnedAppBundleIDs == ["app1", "app2"])
    }

    // MARK: - Thumbnails

    @Test("requestThumbnail returns nil without permission")
    func requestThumbnailNoPermission() async {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.screenRecordingPermission = false

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: mockPermissionManager
        )

        appState.start()

        let thumbnail = await appState.requestThumbnail(for: 1)
        #expect(thumbnail == nil)
    }

    @Test("requestThumbnail returns image with permission")
    func requestThumbnailWithPermission() async {
        let mockPermissionManager = MockPermissionManager()
        mockPermissionManager.screenRecordingPermission = true

        let mockThumbnailProvider = MockThumbnailProvider()

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: mockThumbnailProvider,
            permissionManager: mockPermissionManager
        )

        appState.start()

        let thumbnail = await appState.requestThumbnail(for: 123)

        #expect(thumbnail != nil)
        let captureCount = await mockThumbnailProvider.captureCallCount
        #expect(captureCount == 1)
    }

    // MARK: - App Activation Callback

    @Test("onAppActivated updates activeAppBundleID")
    func onAppActivatedCallback() {
        let mockAppMonitor = MockAppMonitor()

        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: mockAppMonitor,
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        appState.start()

        // Simulate app activation
        mockAppMonitor.simulateAppActivated("com.apple.Safari")

        #expect(appState.activeAppBundleID == "com.apple.Safari")
    }

    // MARK: - Settings Changed Callback

    @Test("onSettingsChanged callback is invoked")
    func onSettingsChangedCallback() {
        let appState = AppState(
            settingsStore: MockSettingsStore(),
            appMonitor: MockAppMonitor(),
            windowMonitor: MockWindowMonitor(),
            thumbnailProvider: MockThumbnailProvider(),
            permissionManager: MockPermissionManager()
        )

        var callbackInvoked = false
        appState.onSettingsChanged = {
            callbackInvoked = true
        }

        appState.settings.height = 100

        #expect(callbackInvoked == true)
    }
}
