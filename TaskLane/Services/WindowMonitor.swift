import AppKit
import CoreGraphics
import Foundation

/// Retrieves window information via CGWindowListCopyWindowInfo
final class WindowMonitor: WindowMonitorProtocol, Sendable {

    /// Get all visible windows grouped by owning application bundle ID
    @MainActor
    func getWindowsGroupedByApp() -> [String: [WindowInfo]] {
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [CFDictionary] else {
            return [:]
        }

        var result: [String: [WindowInfo]] = [:]

        for dict in windowList {
            guard let info = WindowInfo(from: dict),
                  info.isNormalWindow
            else { continue }

            // Get bundle ID from PID
            if let app = NSRunningApplication(processIdentifier: info.ownerPID),
               let bundleID = app.bundleIdentifier {
                result[bundleID, default: []].append(info)
            }
        }

        return result
    }

    /// Get windows for a specific application
    @MainActor
    func getWindows(for bundleID: String) -> [WindowInfo] {
        getWindowsGroupedByApp()[bundleID] ?? []
    }

    /// Get total window count for an application
    @MainActor
    func getWindowCount(for bundleID: String) -> Int {
        getWindows(for: bundleID).count
    }

    /// Get all windows (flat list)
    @MainActor
    func getAllWindows() -> [WindowInfo] {
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [CFDictionary] else {
            return []
        }

        return windowList.compactMap { WindowInfo(from: $0) }
            .filter { $0.isNormalWindow }
    }
}
