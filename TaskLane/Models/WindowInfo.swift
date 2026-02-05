import CoreGraphics
import Foundation

/// Window information from CGWindowListCopyWindowInfo
struct WindowInfo: Identifiable, Sendable {
    let id: CGWindowID
    let ownerPID: pid_t
    let ownerName: String
    let name: String?          // Requires Screen Recording permission
    let bounds: CGRect
    let layer: Int
    let isOnScreen: Bool
    let alpha: CGFloat

    /// Initialize from a CGWindowList dictionary
    init?(from dict: CFDictionary) {
        guard let d = dict as? [CFString: Any] else { return nil }

        // Required fields
        guard let windowID = d[kCGWindowNumber] as? CGWindowID,
              let pid = d[kCGWindowOwnerPID] as? pid_t,
              let ownerName = d[kCGWindowOwnerName] as? String,
              let layer = d[kCGWindowLayer] as? Int
        else { return nil }

        self.id = windowID
        self.ownerPID = pid
        self.ownerName = ownerName
        self.layer = layer

        // Optional fields
        self.name = d[kCGWindowName] as? String  // nil without Screen Recording permission
        self.isOnScreen = (d[kCGWindowIsOnscreen] as? Bool) ?? false
        self.alpha = (d[kCGWindowAlpha] as? CGFloat) ?? 1.0

        // Parse bounds
        if let boundsDict = d[kCGWindowBounds] as? [String: CGFloat] {
            self.bounds = CGRect(
                x: boundsDict["X"] ?? 0,
                y: boundsDict["Y"] ?? 0,
                width: boundsDict["Width"] ?? 0,
                height: boundsDict["Height"] ?? 0
            )
        } else {
            self.bounds = .zero
        }
    }

    /// Display name for the window (falls back to generic name if no permission)
    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return String(localized: "Window \(id)")
    }

    /// Check if this is a normal window (not a menu, dock tile, etc.)
    var isNormalWindow: Bool {
        layer == 0 && isOnScreen && bounds.width > 50 && bounds.height > 50
    }
}
