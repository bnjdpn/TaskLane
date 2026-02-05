@preconcurrency import AppKit
import Observation
import SwiftUI

/// Global observable application state
@Observable
@MainActor
final class AppState {

    // MARK: - Settings

    var settings: TaskLaneSettings {
        didSet {
            settingsStore.save(settings)
            onSettingsChanged?()
        }
    }

    // MARK: - Runtime State

    var taskbarItems: [TaskbarItem] = []
    var activeAppBundleID: String?
    var windowsByApp: [String: [WindowInfo]] = [:]

    // MARK: - Show Desktop State

    private(set) var isDesktopShown = false
    private var appsHiddenForDesktop: [NSRunningApplication] = []

    // MARK: - Permissions

    var hasScreenRecordingPermission: Bool = false

    // MARK: - Callbacks

    var onSettingsChanged: (() -> Void)?

    // MARK: - Services

    private let settingsStore: any SettingsStoreProtocol
    private let appMonitor: any AppMonitorProtocol
    private let windowMonitor: any WindowMonitorProtocol
    private let thumbnailProvider: any ThumbnailProviderProtocol
    private let permissionManager: any PermissionManagerProtocol

    // MARK: - Initialization

    init(
        settingsStore: (any SettingsStoreProtocol)? = nil,
        appMonitor: (any AppMonitorProtocol)? = nil,
        windowMonitor: (any WindowMonitorProtocol)? = nil,
        thumbnailProvider: (any ThumbnailProviderProtocol)? = nil,
        permissionManager: (any PermissionManagerProtocol)? = nil
    ) {
        self.settingsStore = settingsStore ?? SettingsStore()
        self.appMonitor = appMonitor ?? AppMonitor()
        self.windowMonitor = windowMonitor ?? WindowMonitor()
        self.thumbnailProvider = thumbnailProvider ?? ThumbnailProvider()
        self.permissionManager = permissionManager ?? PermissionManager()
        self.settings = self.settingsStore.load()

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        appMonitor.onAppsChanged = { [weak self] apps in
            self?.updateTaskbarItems(from: apps)
        }

        appMonitor.onAppActivated = { [weak self] bundleID in
            self?.activeAppBundleID = bundleID
        }
    }

    // MARK: - Lifecycle

    func start() {
        Log.app.info("TaskLane starting")
        appMonitor.startMonitoring()
        checkPermissions()
        refreshWindowList()
        Log.app.info("TaskLane started with \(self.taskbarItems.count) taskbar items")
    }

    func stop() {
        appMonitor.stopMonitoring()
    }

    // MARK: - Taskbar Items

    private func updateTaskbarItems(from runningApps: [NSRunningApplication]) {
        var items: [TaskbarItem] = []
        _ = Set(runningApps.compactMap(\.bundleIdentifier))  // For future use

        // Add pinned apps first (in order)
        for bundleID in settings.pinnedAppBundleIDs {
            if let runningApp = runningApps.first(where: { $0.bundleIdentifier == bundleID }) {
                // Pinned and running
                var item = TaskbarItem.from(runningApp: runningApp, isPinned: true)
                item.windowCount = windowsByApp[bundleID]?.count ?? 0
                items.append(item)
            } else {
                // Pinned but not running
                if let item = TaskbarItem.pinnedItem(bundleID: bundleID) {
                    items.append(item)
                }
            }
        }

        // Add running apps that aren't pinned - only if they have visible windows
        let appsWithVisibleWindows = Set(windowsByApp.keys)
        for app in runningApps {
            guard let bundleID = app.bundleIdentifier,
                  !settings.pinnedAppBundleIDs.contains(bundleID),
                  appsWithVisibleWindows.contains(bundleID)  // Only show if has visible windows
            else { continue }

            var item = TaskbarItem.from(runningApp: app, isPinned: false)
            item.windowCount = windowsByApp[bundleID]?.count ?? 0
            items.append(item)
        }

        self.taskbarItems = items
    }

    // MARK: - Permissions

    private func checkPermissions() {
        let hadPermission = hasScreenRecordingPermission
        hasScreenRecordingPermission = permissionManager.hasScreenRecording()

        if hasScreenRecordingPermission != hadPermission {
            Log.permissions.info("Screen Recording permission: \(self.hasScreenRecordingPermission ? "granted" : "denied")")
        }
    }

    func recheckPermissions() {
        checkPermissions()
        if hasScreenRecordingPermission {
            refreshWindowList()
        }
    }

    // MARK: - Window List

    func refreshWindowList() {
        windowsByApp = windowMonitor.getWindowsGroupedByApp()

        // Rebuild taskbar items with new window data
        // This ensures apps without visible windows are removed
        let runningApps = appMonitor.getRunningApps()
        updateTaskbarItems(from: runningApps)
    }

    // MARK: - App Actions

    func activateApp(_ item: TaskbarItem) {
        if let pid = item.processIdentifier,
           let app = NSRunningApplication(processIdentifier: pid) {
            // App is running - activate it
            app.activate()
        } else {
            // App is not running - launch it
            launchApp(bundleID: item.bundleIdentifier)
        }
    }

    private func launchApp(bundleID: String) {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error {
                Log.app.error("Failed to launch app \(bundleID): \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Pin/Unpin

    func pinApp(_ bundleID: String) {
        if !settings.pinnedAppBundleIDs.contains(bundleID) {
            settings.pinnedAppBundleIDs.append(bundleID)
        }
    }

    func unpinApp(_ bundleID: String) {
        settings.pinnedAppBundleIDs.removeAll { $0 == bundleID }
    }

    func movePinnedApp(from source: Int, to destination: Int) {
        guard source >= 0, source < settings.pinnedAppBundleIDs.count,
              destination >= 0, destination <= settings.pinnedAppBundleIDs.count
        else { return }

        let item = settings.pinnedAppBundleIDs.remove(at: source)
        let adjustedDestination = destination > source ? destination - 1 : destination
        settings.pinnedAppBundleIDs.insert(item, at: max(0, adjustedDestination))
    }

    // MARK: - Thumbnails

    func requestThumbnail(for windowID: CGWindowID) async -> NSImage? {
        guard hasScreenRecordingPermission else { return nil }
        return await thumbnailProvider.capture(windowID: windowID)
    }

    // MARK: - Show Desktop

    /// Toggle between showing desktop (hiding all apps) and restoring them
    func toggleShowDesktop() {
        if isDesktopShown {
            restoreFromDesktop()
        } else {
            showDesktop()
        }
    }

    private func showDesktop() {
        // Get all running apps (excluding self and system apps)
        let runningApps = NSWorkspace.shared.runningApplications.filter { app in
            app.activationPolicy == .regular && !app.isHidden
        }

        // Hide all visible apps
        appsHiddenForDesktop = runningApps
        for app in runningApps {
            app.hide()
        }

        isDesktopShown = true
        Log.app.debug("Show Desktop: hid \(runningApps.count) apps")
    }

    private func restoreFromDesktop() {
        // Unhide previously hidden apps
        let count = appsHiddenForDesktop.count
        for app in appsHiddenForDesktop {
            app.unhide()
        }

        appsHiddenForDesktop = []
        isDesktopShown = false
        Log.app.debug("Restore from Desktop: restored \(count) apps")
    }
}
