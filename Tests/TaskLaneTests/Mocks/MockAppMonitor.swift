import AppKit
@testable import TaskLane

@MainActor
final class MockAppMonitor: AppMonitorProtocol {
    // MARK: - Protocol Properties

    var onAppsChanged: (([NSRunningApplication]) -> Void)?
    var onAppActivated: ((String?) -> Void)?

    // MARK: - Configurable State

    var runningApps: [NSRunningApplication] = []
    var isMonitoring = false

    // MARK: - Call Tracking

    var startMonitoringCallCount = 0
    var stopMonitoringCallCount = 0
    var refreshAppsCallCount = 0
    var getRunningAppsCallCount = 0

    // MARK: - Protocol Implementation

    func startMonitoring() {
        startMonitoringCallCount += 1
        isMonitoring = true
        onAppsChanged?(runningApps)
    }

    func stopMonitoring() {
        stopMonitoringCallCount += 1
        isMonitoring = false
    }

    func refreshApps() {
        refreshAppsCallCount += 1
        onAppsChanged?(runningApps)
    }

    func getRunningApps() -> [NSRunningApplication] {
        getRunningAppsCallCount += 1
        return runningApps
    }

    // MARK: - Test Helpers

    func simulateAppsChanged(_ apps: [NSRunningApplication]) {
        runningApps = apps
        onAppsChanged?(apps)
    }

    func simulateAppActivated(_ bundleID: String?) {
        onAppActivated?(bundleID)
    }

    func reset() {
        runningApps = []
        isMonitoring = false
        startMonitoringCallCount = 0
        stopMonitoringCallCount = 0
        refreshAppsCallCount = 0
        getRunningAppsCallCount = 0
        onAppsChanged = nil
        onAppActivated = nil
    }
}
