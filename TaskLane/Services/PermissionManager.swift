import AppKit
import ApplicationServices
import CoreGraphics
import ScreenCaptureKit

/// Manages permission checking and requesting
@MainActor
final class PermissionManager: PermissionManagerProtocol {

    // MARK: - Singleton

    static let shared = PermissionManager()

    init() {}

    // MARK: - Screen Recording

    /// Check if Screen Recording permission is granted
    func hasScreenRecording() -> Bool {
        CGPreflightScreenCaptureAccess()
    }

    /// Request Screen Recording permission (triggers system dialog)
    func requestScreenRecording() {
        CGRequestScreenCaptureAccess()
    }

    /// Open System Settings to Screen Recording pane
    func openScreenRecordingSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Check permission by attempting to get window names
    /// This is a more reliable check as it verifies actual capability
    func hasScreenRecordingByWindowCheck() -> Bool {
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
        let hasWindows = !windowList.isEmpty
        if hasWindows {
            return false
        }

        return CGPreflightScreenCaptureAccess()
    }

    // MARK: - Accessibility

    /// Check if Accessibility permission is granted
    func hasAccessibilityPermission() -> Bool {
        AXIsProcessTrusted()
    }

    /// Request Accessibility permission (opens System Settings)
    func requestAccessibilityPermission() {
        let key = "AXTrustedCheckOptionPrompt" as CFString
        let options = [key: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Permission Status

    enum PermissionStatus: Sendable {
        case granted
        case denied
        case unknown
    }

    /// Get detailed permission status
    func screenRecordingStatus() -> PermissionStatus {
        if CGPreflightScreenCaptureAccess() {
            return .granted
        }
        return .denied
    }
}
