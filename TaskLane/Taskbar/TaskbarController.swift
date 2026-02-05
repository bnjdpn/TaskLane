import AppKit
import SwiftUI

/// Manages taskbar panels across all screens
@MainActor
final class TaskbarController {

    // MARK: - Properties

    private var panels: [String: TaskbarPanel] = [:]  // Screen ID -> Panel
    private var screenObserver: NSObjectProtocol?

    weak var appState: AppState?

    // MARK: - Lifecycle

    deinit {
        // Clean up on deinit - only called when all references are released
    }

    // MARK: - Setup

    /// Initialize the taskbar controller with app state
    func setup(with appState: AppState) {
        self.appState = appState

        // Observe screen configuration changes
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleScreensChanged()
            }
        }

        // Create initial panels
        updatePanels()
    }

    /// Clean up all panels and observers
    func teardown() {
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
            screenObserver = nil
        }

        for panel in panels.values {
            panel.orderOut(nil)
            panel.close()
        }
        panels.removeAll()
    }

    // MARK: - Panel Management

    /// Update panels based on current settings and screen configuration
    func updatePanels() {
        guard let appState else { return }
        let settings = appState.settings

        // Determine which screens should have panels
        let targetScreens = getTargetScreens(for: settings)
        let targetIDs = Set(targetScreens.map(\.identifier))

        // Remove panels for screens that are no longer targeted
        for (id, panel) in panels where !targetIDs.contains(id) {
            panel.orderOut(nil)
            panel.close()
            panels.removeValue(forKey: id)
        }

        // Create or update panels for target screens
        for screen in targetScreens {
            let id = screen.identifier

            if let panel = panels[id] {
                // Update existing panel position
                panel.position(at: settings.position, size: settings.height)
            } else {
                // Create new panel
                let panel = createPanel(for: screen, settings: settings)
                panels[id] = panel
            }
        }
    }

    /// Refresh the layout of all panels (e.g., after settings change)
    func refreshLayout() {
        updatePanels()
    }

    // MARK: - Private Methods

    private func getTargetScreens(for settings: TaskLaneSettings) -> [NSScreen] {
        if settings.showOnAllScreens {
            return NSScreen.screens
        } else if settings.primaryScreenOnly {
            if let main = NSScreen.main {
                return [main]
            }
            return []
        } else if let screenID = settings.selectedScreenID,
                  let screen = NSScreen.screens.first(where: { $0.identifier == screenID }) {
            return [screen]
        } else {
            // Fallback to primary screen
            if let main = NSScreen.main {
                return [main]
            }
            return []
        }
    }

    private func createPanel(for screen: NSScreen, settings: TaskLaneSettings) -> TaskbarPanel {
        let panel = TaskbarPanel(screen: screen)

        // Create the SwiftUI content with environment
        let content = TaskbarView()
            .environment(appState!)

        panel.setContent(content)

        // Position the panel
        panel.position(at: settings.position, size: settings.height)

        // Show the panel
        panel.orderFrontRegardless()

        return panel
    }

    private func handleScreensChanged() {
        // Screens have changed - update panel configuration
        updatePanels()
    }
}
