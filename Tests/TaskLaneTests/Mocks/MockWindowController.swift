import AppKit
@testable import TaskLane

@MainActor
final class MockWindowController: WindowControllerProtocol {
    // MARK: - Configurable State

    var shouldSucceed = true

    // MARK: - Call Tracking

    var focusWindowCallCount = 0
    var closeWindowCallCount = 0
    var minimizeWindowCallCount = 0
    var unminimizeWindowCallCount = 0

    var lastFocusedWindowID: CGWindowID?
    var lastClosedWindowID: CGWindowID?
    var lastMinimizedWindowID: CGWindowID?
    var lastUnminimizedWindowID: CGWindowID?

    // MARK: - Protocol Implementation

    func focusWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        focusWindowCallCount += 1
        lastFocusedWindowID = windowID
        return shouldSucceed
    }

    func closeWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        closeWindowCallCount += 1
        lastClosedWindowID = windowID
        return shouldSucceed
    }

    func minimizeWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        minimizeWindowCallCount += 1
        lastMinimizedWindowID = windowID
        return shouldSucceed
    }

    func unminimizeWindow(windowID: CGWindowID, pid: pid_t) -> Bool {
        unminimizeWindowCallCount += 1
        lastUnminimizedWindowID = windowID
        return shouldSucceed
    }

    // MARK: - Test Helpers

    func reset() {
        shouldSucceed = true
        focusWindowCallCount = 0
        closeWindowCallCount = 0
        minimizeWindowCallCount = 0
        unminimizeWindowCallCount = 0
        lastFocusedWindowID = nil
        lastClosedWindowID = nil
        lastMinimizedWindowID = nil
        lastUnminimizedWindowID = nil
    }
}
