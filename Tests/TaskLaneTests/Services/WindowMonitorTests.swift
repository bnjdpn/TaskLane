import Testing
import Foundation
import CoreGraphics
@testable import TaskLane

@Suite("WindowMonitor Tests")
@MainActor
struct WindowMonitorTests {

    // MARK: - Initialization

    @Test("WindowMonitor can be instantiated")
    func canInstantiate() {
        let monitor = WindowMonitor()
        #expect(monitor != nil)
    }

    // MARK: - getWindowsGroupedByApp

    @Test("getWindowsGroupedByApp returns dictionary")
    func getWindowsGroupedByAppReturnsDictionary() {
        let monitor = WindowMonitor()

        let result = monitor.getWindowsGroupedByApp()

        // Should return a dictionary (may be empty without permission)
        #expect(result is [String: [WindowInfo]])
    }

    @Test("getWindowsGroupedByApp has valid bundle IDs as keys")
    func getWindowsGroupedByAppHasValidKeys() {
        let monitor = WindowMonitor()

        let result = monitor.getWindowsGroupedByApp()

        // All keys should be non-empty strings (bundle IDs)
        for key in result.keys {
            #expect(!key.isEmpty)
        }
    }

    @Test("getWindowsGroupedByApp values are non-empty arrays")
    func getWindowsGroupedByAppValuesNonEmpty() {
        let monitor = WindowMonitor()

        let result = monitor.getWindowsGroupedByApp()

        // All values should be non-empty arrays
        for (_, windows) in result {
            #expect(!windows.isEmpty)
        }
    }

    // MARK: - getWindows

    @Test("getWindows returns array for valid bundle ID")
    func getWindowsReturnsArray() {
        let monitor = WindowMonitor()

        // Use a known system bundle ID
        let result = monitor.getWindows(for: "com.apple.finder")

        // Should return an array (may be empty)
        #expect(result is [WindowInfo])
    }

    @Test("getWindows returns empty array for non-existent bundle ID")
    func getWindowsReturnsEmptyForNonExistent() {
        let monitor = WindowMonitor()

        let result = monitor.getWindows(for: "com.nonexistent.app.that.does.not.exist")

        #expect(result.isEmpty)
    }

    @Test("getWindows consistent with getWindowsGroupedByApp")
    func getWindowsConsistentWithGrouped() {
        let monitor = WindowMonitor()

        let grouped = monitor.getWindowsGroupedByApp()

        for (bundleID, expectedWindows) in grouped {
            let windows = monitor.getWindows(for: bundleID)
            #expect(windows.count == expectedWindows.count)
        }
    }

    // MARK: - getWindowCount

    @Test("getWindowCount returns integer")
    func getWindowCountReturnsInteger() {
        let monitor = WindowMonitor()

        let count = monitor.getWindowCount(for: "com.apple.finder")

        #expect(count >= 0)
    }

    @Test("getWindowCount returns zero for non-existent bundle ID")
    func getWindowCountZeroForNonExistent() {
        let monitor = WindowMonitor()

        let count = monitor.getWindowCount(for: "com.nonexistent.app")

        #expect(count == 0)
    }

    @Test("getWindowCount matches getWindows count")
    func getWindowCountMatchesGetWindows() {
        let monitor = WindowMonitor()

        let grouped = monitor.getWindowsGroupedByApp()

        for bundleID in grouped.keys {
            let count = monitor.getWindowCount(for: bundleID)
            let windows = monitor.getWindows(for: bundleID)
            #expect(count == windows.count)
        }
    }

    // MARK: - getAllWindows

    @Test("getAllWindows returns array")
    func getAllWindowsReturnsArray() {
        let monitor = WindowMonitor()

        let result = monitor.getAllWindows()

        #expect(result is [WindowInfo])
    }

    @Test("getAllWindows count matches grouped sum")
    func getAllWindowsCountMatchesGroupedSum() {
        let monitor = WindowMonitor()

        let allWindows = monitor.getAllWindows()
        let grouped = monitor.getWindowsGroupedByApp()

        let groupedSum = grouped.values.reduce(0) { $0 + $1.count }

        #expect(allWindows.count == groupedSum)
    }

    @Test("getAllWindows returns only normal windows")
    func getAllWindowsReturnsOnlyNormalWindows() {
        let monitor = WindowMonitor()

        let allWindows = monitor.getAllWindows()

        // All returned windows should be "normal" windows
        for window in allWindows {
            #expect(window.isNormalWindow == true)
        }
    }

    // MARK: - Thread Safety

    @Test("Multiple calls are safe")
    func multipleCallsSafe() {
        let monitor = WindowMonitor()

        // Multiple rapid calls should be safe
        for _ in 0..<10 {
            _ = monitor.getWindowsGroupedByApp()
            _ = monitor.getAllWindows()
            _ = monitor.getWindows(for: "com.apple.finder")
            _ = monitor.getWindowCount(for: "com.apple.finder")
        }
    }
}
