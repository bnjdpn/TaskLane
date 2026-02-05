@preconcurrency import AppKit
import Foundation

/// Represents an item in the taskbar (pinned or running app)
/// Note: NSImage is thread-safe and Sendable on macOS 14+
struct TaskbarItem: Identifiable, Hashable, @unchecked Sendable {
    let id: UUID
    let bundleIdentifier: String
    let displayName: String
    let icon: NSImage
    var isPinned: Bool
    var isRunning: Bool
    var windowCount: Int
    var processIdentifier: pid_t?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        bundleIdentifier: String,
        displayName: String,
        icon: NSImage,
        isPinned: Bool,
        isRunning: Bool,
        windowCount: Int = 0,
        processIdentifier: pid_t? = nil
    ) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.icon = icon
        self.isPinned = isPinned
        self.isRunning = isRunning
        self.windowCount = windowCount
        self.processIdentifier = processIdentifier
    }

    /// Create from a running application
    @MainActor
    static func from(runningApp: NSRunningApplication, isPinned: Bool = false) -> TaskbarItem {
        TaskbarItem(
            bundleIdentifier: runningApp.bundleIdentifier ?? "",
            displayName: runningApp.localizedName ?? "Unknown",
            icon: runningApp.icon ?? NSImage(systemSymbolName: "app", accessibilityDescription: nil) ?? NSImage(),
            isPinned: isPinned,
            isRunning: true,
            windowCount: 0,
            processIdentifier: runningApp.processIdentifier
        )
    }

    /// Create a pinned item that is not running
    @MainActor
    static func pinnedItem(bundleID: String) -> TaskbarItem? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }

        let icon = NSWorkspace.shared.icon(forFile: url.path)
        let name = FileManager.default.displayName(atPath: url.path)
            .replacingOccurrences(of: ".app", with: "")

        return TaskbarItem(
            bundleIdentifier: bundleID,
            displayName: name,
            icon: icon,
            isPinned: true,
            isRunning: false,
            windowCount: 0,
            processIdentifier: nil
        )
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }

    static func == (lhs: TaskbarItem, rhs: TaskbarItem) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}

// Note: NSImage is Sendable as of macOS 14+ via AppKit
