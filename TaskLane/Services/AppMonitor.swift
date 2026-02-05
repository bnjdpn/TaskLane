import AppKit
import Foundation

/// Monitors running applications via NSWorkspace notifications
@MainActor
final class AppMonitor: AppMonitorProtocol {
    // MARK: - Callbacks

    var onAppsChanged: (([NSRunningApplication]) -> Void)?
    var onAppActivated: ((String?) -> Void)?

    // MARK: - Private Properties

    private var observers: [NSObjectProtocol] = []
    private let workspace = NSWorkspace.shared
    private let debouncer = Debouncer(delay: 0.2)
    private var isMonitoring = false

    // MARK: - Lifecycle

    nonisolated deinit {
        // Cannot call MainActor methods from deinit
        // Observers will be cleaned up when the workspace notification center is deallocated
    }

    // MARK: - Public Methods

    /// Start monitoring application events
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        let nc = workspace.notificationCenter

        // App launched
        observers.append(nc.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleAppsChanged()
            }
        })

        // App terminated
        observers.append(nc.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleAppsChanged()
            }
        })

        // App activated
        observers.append(nc.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // Extract bundle ID from notification in the closure context
            let bundleID = (notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier
            MainActor.assumeIsolated {
                self?.onAppActivated?(bundleID)
            }
        })

        // App hidden/unhidden
        observers.append(nc.addObserver(
            forName: NSWorkspace.didHideApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleAppsChanged()
            }
        })

        observers.append(nc.addObserver(
            forName: NSWorkspace.didUnhideApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleAppsChanged()
            }
        })

        // Initial state
        handleAppsChanged()
        onAppActivated?(workspace.frontmostApplication?.bundleIdentifier)
    }

    /// Stop monitoring application events
    func stopMonitoring() {
        isMonitoring = false
        for observer in observers {
            workspace.notificationCenter.removeObserver(observer)
        }
        observers.removeAll()
    }

    /// Force refresh the app list
    func refreshApps() {
        handleAppsChanged()
    }

    /// Get current running applications (GUI apps only)
    func getRunningApps() -> [NSRunningApplication] {
        workspace.runningApplications.filter {
            $0.activationPolicy == .regular
        }
    }

    // MARK: - Private Methods

    private func handleAppsChanged() {
        debouncer.debounce { [weak self] in
            guard let self else { return }
            let apps = self.getRunningApps()
            self.onAppsChanged?(apps)
        }
    }

}

// MARK: - Debouncer

/// Simple debouncer for coalescing rapid events
@MainActor
final class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func debounce(action: @escaping @MainActor () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            MainActor.assumeIsolated {
                guard self?.workItem?.isCancelled == false else { return }
                action()
            }
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
