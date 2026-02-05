import AppKit
import CoreGraphics
import ScreenCaptureKit

/// Manages permission checking and requesting
enum PermissionManager {

    // MARK: - Screen Recording

    /// Check if Screen Recording permission is granted
    @MainActor
    static func hasScreenRecording() -> Bool {
        // CGPreflightScreenCaptureAccess returns true if permission is granted
        return CGPreflightScreenCaptureAccess()
    }

    /// Request Screen Recording permission (triggers system dialog)
    @MainActor
    static func requestScreenRecording() {
        // This will trigger the system permission dialog if not already granted
        CGRequestScreenCaptureAccess()
    }

    /// Open System Settings to Screen Recording pane
    @MainActor
    static func openScreenRecordingSettings() {
        // Deep link to Privacy & Security > Screen Recording
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Check permission by attempting to get window names
    /// This is a more reliable check as it verifies actual capability
    @MainActor
    static func hasScreenRecordingByWindowCheck() -> Bool {
        guard let windowList = CGWindowListCopyWindowInfo(
            .optionOnScreenOnly,
            kCGNullWindowID
        ) as? [[CFString: Any]] else {
            return false
        }

        // If we can get any window name, we have permission
        for dict in windowList {
            if let name = dict[kCGWindowName] as? String, !name.isEmpty {
                return true
            }
        }

        // Check if there are any windows to test against
        // If no windows have names and there are windows, we likely don't have permission
        let hasWindows = !windowList.isEmpty
        if hasWindows {
            // We have windows but no names - likely no permission
            return false
        }

        // No windows to test - fall back to preflight check
        return CGPreflightScreenCaptureAccess()
    }

    // MARK: - Permission Status

    enum PermissionStatus: Sendable {
        case granted
        case denied
        case unknown
    }

    /// Get detailed permission status
    @MainActor
    static func screenRecordingStatus() -> PermissionStatus {
        if CGPreflightScreenCaptureAccess() {
            return .granted
        }
        // We can't easily distinguish between "denied" and "not yet asked"
        // without actually requesting, so we return denied to be safe
        return .denied
    }
}
