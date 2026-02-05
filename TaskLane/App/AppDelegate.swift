import AppKit
import SwiftUI

/// Application delegate handling lifecycle and menu bar
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    let appState = AppState()
    private var taskbarController: TaskbarController?
    private var statusItem: NSStatusItem?
    private var refreshTimer: Timer?
    private var settingsWindow: NSWindow?
    private var spaceChangeObserver: NSObjectProtocol?

    // MARK: - NSApplicationDelegate

    nonisolated func applicationDidFinishLaunching(_ notification: Notification) {
        Task { @MainActor in
            self.setupApp()
        }
    }

    nonisolated func applicationWillTerminate(_ notification: Notification) {
        Task { @MainActor in
            self.teardownApp()
        }
    }

    nonisolated func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Task { @MainActor in
            self.openSettings()
        }
        return true
    }

    // MARK: - Setup

    private func setupApp() {
        // Configure as accessory app (no dock icon)
        NSApp.setActivationPolicy(.accessory)

        // Setup menu bar status item
        setupStatusItem()

        // Setup and show taskbar
        taskbarController = TaskbarController()
        taskbarController?.setup(with: appState)

        // Listen for settings changes to update taskbar
        appState.onSettingsChanged = { [weak self] in
            self?.taskbarController?.refreshLayout()
        }

        // Start monitoring
        appState.start()

        // Observe Space/Desktop changes
        setupSpaceChangeObserver()

        // Periodic window list refresh (every 2 seconds when app is active)
        setupWindowRefreshTimer()
    }

    private func teardownApp() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        if let observer = spaceChangeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            spaceChangeObserver = nil
        }
        appState.stop()
        taskbarController?.teardown()
    }

    // MARK: - Menu Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "rectangle.split.3x1",
                accessibilityDescription: "TaskLane"
            )
            button.image?.isTemplate = true
        }

        let menu = NSMenu()

        // Settings
        let settingsItem = NSMenuItem(
            title: String(localized: "Settings..."),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        // Refresh windows
        let refreshItem = NSMenuItem(
            title: String(localized: "Refresh Windows"),
            action: #selector(refreshWindows),
            keyEquivalent: "r"
        )
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: String(localized: "Quit TaskLane"),
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    // MARK: - Actions

    @objc private func openSettings() {
        if settingsWindow == nil {
            settingsWindow = createSettingsWindow()
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createSettingsWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "TaskLane Settings")
        window.contentView = NSHostingView(rootView: SettingsView().environment(appState))
        window.center()
        window.isReleasedWhenClosed = false
        return window
    }

    @objc private func refreshWindows() {
        appState.refreshWindowList()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    // MARK: - Space Change Observer

    private func setupSpaceChangeObserver() {
        // Observe when user switches to a different Space/Desktop
        spaceChangeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                // Small delay to let the Space transition complete
                try? await Task.sleep(for: .milliseconds(100))
                self?.appState.refreshWindowList()
            }
        }
    }

    // MARK: - Window Refresh Timer

    private func setupWindowRefreshTimer() {
        // Refresh window list periodically
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.appState.refreshWindowList()
            }
        }
    }
}
