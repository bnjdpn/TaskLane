import AppKit
@testable import TaskLane

@MainActor
final class MockWindowMonitor: WindowMonitorProtocol, Sendable {
    // MARK: - Configurable State

    var windowsByApp: [String: [WindowInfo]] = [:]
    var allWindows: [WindowInfo] = []

    // MARK: - Call Tracking

    var getWindowsGroupedByAppCallCount = 0
    var getWindowsCallCount = 0
    var getWindowCountCallCount = 0
    var getAllWindowsCallCount = 0

    // MARK: - Protocol Implementation

    func getWindowsGroupedByApp() -> [String: [WindowInfo]] {
        getWindowsGroupedByAppCallCount += 1
        return windowsByApp
    }

    func getWindows(for bundleID: String) -> [WindowInfo] {
        getWindowsCallCount += 1
        return windowsByApp[bundleID] ?? []
    }

    func getWindowCount(for bundleID: String) -> Int {
        getWindowCountCallCount += 1
        return windowsByApp[bundleID]?.count ?? 0
    }

    func getAllWindows() -> [WindowInfo] {
        getAllWindowsCallCount += 1
        return allWindows
    }

    // MARK: - Test Helpers

    func reset() {
        windowsByApp = [:]
        allWindows = []
        getWindowsGroupedByAppCallCount = 0
        getWindowsCallCount = 0
        getWindowCountCallCount = 0
        getAllWindowsCallCount = 0
    }
}
