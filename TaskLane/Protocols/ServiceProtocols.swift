import AppKit
import CoreGraphics

// MARK: - WindowMonitorProtocol

/// Protocol for monitoring and retrieving window information
@MainActor
protocol WindowMonitorProtocol: Sendable {
    /// Get all visible windows grouped by owning application bundle ID
    func getWindowsGroupedByApp() -> [String: [WindowInfo]]

    /// Get windows for a specific application
    func getWindows(for bundleID: String) -> [WindowInfo]

    /// Get total window count for an application
    func getWindowCount(for bundleID: String) -> Int

    /// Get all windows (flat list)
    func getAllWindows() -> [WindowInfo]
}

// MARK: - AppMonitorProtocol

/// Protocol for monitoring running applications
@MainActor
protocol AppMonitorProtocol: AnyObject {
    /// Callback when the list of running apps changes
    var onAppsChanged: (([NSRunningApplication]) -> Void)? { get set }

    /// Callback when an app is activated
    var onAppActivated: ((String?) -> Void)? { get set }

    /// Start monitoring application events
    func startMonitoring()

    /// Stop monitoring application events
    func stopMonitoring()

    /// Force refresh the app list
    func refreshApps()

    /// Get current running applications (GUI apps only)
    func getRunningApps() -> [NSRunningApplication]
}

// MARK: - ThumbnailProviderProtocol

/// Protocol for capturing window thumbnails
protocol ThumbnailProviderProtocol: Actor {
    /// Capture a thumbnail for a specific window
    func capture(windowID: CGWindowID) async -> NSImage?

    /// Clear all cached thumbnails
    func clearCache() async

    /// Invalidate a specific cached thumbnail
    func invalidate(windowID: CGWindowID) async
}

// MARK: - WindowControllerProtocol

/// Protocol for controlling windows via Accessibility APIs
@MainActor
protocol WindowControllerProtocol {
    /// Focus a specific window by its window ID
    func focusWindow(windowID: CGWindowID, pid: pid_t) -> Bool

    /// Close a specific window
    func closeWindow(windowID: CGWindowID, pid: pid_t) -> Bool

    /// Minimize a specific window
    func minimizeWindow(windowID: CGWindowID, pid: pid_t) -> Bool

    /// Unminimize (restore) a specific window
    func unminimizeWindow(windowID: CGWindowID, pid: pid_t) -> Bool
}

// MARK: - PermissionManagerProtocol

/// Protocol for managing system permissions
@MainActor
protocol PermissionManagerProtocol {
    /// Check if Screen Recording permission is granted
    func hasScreenRecording() -> Bool

    /// Request Screen Recording permission
    func requestScreenRecording()

    /// Open System Settings to Screen Recording pane
    func openScreenRecordingSettings()

    /// Check if Accessibility permission is granted
    func hasAccessibilityPermission() -> Bool

    /// Request Accessibility permission
    func requestAccessibilityPermission()
}

// MARK: - SettingsStoreProtocol

/// Protocol for persisting and retrieving settings
@MainActor
protocol SettingsStoreProtocol {
    /// Load settings
    func load() -> TaskLaneSettings

    /// Save settings
    func save(_ settings: TaskLaneSettings)

    /// Reset settings to defaults
    func reset()

    /// Add a pinned app
    func addPinnedApp(_ bundleID: String)

    /// Remove a pinned app
    func removePinnedApp(_ bundleID: String)

    /// Move a pinned app to a new position
    func movePinnedApp(from source: Int, to destination: Int)
}
