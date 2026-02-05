import AppKit
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

    // MARK: - Permissions

    var hasScreenRecordingPermission: Bool = false

    // MARK: - Callbacks

    var onSettingsChanged: (() -> Void)?

    // MARK: - Services

    private let settingsStore: SettingsStore
    private let appMonitor: AppMonitor
    private let windowMonitor: WindowMonitor
    private let thumbnailProvider: ThumbnailProvider

    // MARK: - Initialization

    init() {
        self.settingsStore = SettingsStore()
        self.settings = settingsStore.load()
        self.appMonitor = AppMonitor()
        self.windowMonitor = WindowMonitor()
        self.thumbnailProvider = ThumbnailProvider()

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
        appMonitor.startMonitoring()
        checkPermissions()
        refreshWindowList()
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
        hasScreenRecordingPermission = PermissionManager.hasScreenRecording()
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
                print("Failed to launch app: \(error)")
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
}
